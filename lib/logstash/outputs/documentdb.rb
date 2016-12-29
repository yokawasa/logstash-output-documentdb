# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'time'
require 'securerandom'
require_relative 'documentdb/client'
require_relative 'documentdb/partitioned_coll_client'
require_relative 'documentdb/header'
require_relative 'documentdb/resource'


class LogStash::Outputs::Documentdb < LogStash::Outputs::Base
  config_name "documentdb"

  config :docdb_endpoint, :validate => :string, :required => true
  config :docdb_account_key, :validate => :string, :required => true
  config :docdb_database, :validate => :string, :required => true
  config :docdb_collection, :validate => :string, :required => true
  config :auto_create_database, :validate => :boolean, :default => true
  config :auto_create_collection, :validate => :boolean, :default => true
  config :partitioned_collection, :validate => :boolean, :default => false
  config :partition_key, :validate => :string, :default => nil
  config :offer_throughput, :validate =>:number, :default => AzureDocumentDB::PARTITIONED_COLL_MIN_THROUGHPUT

  public
  def register
    ## Configure
    if @partitioned_collection
      raise ArgumentError, 'partition_key must be set in partitioned collection mode' if @partition_key.empty?
      if (@auto_create_collection &&
             @offer_throughput < AzureDocumentDB::PARTITIONED_COLL_MIN_THROUGHPUT)
          raise ArgumentError, sprintf("offer_throughput must be more than and equals to %s",
                                 AzureDocumentDB::PARTITIONED_COLL_MIN_THROUGHPUT)
      end
    end

    ## Start 
    begin
      @client = nil
      if @partitioned_collection
        @client = AzureDocumentDB::PartitionedCollectionClient.new(@docdb_account_key,@docdb_endpoint)
      else
        @client = AzureDocumentDB::Client.new(@docdb_account_key,@docdb_endpoint)
      end

      # initial operations for database
      res = @client.find_databases_by_name(@docdb_database)
      if( res[:body]["_count"].to_i == 0 )
        raise RuntimeError, "No database (#{docdb_database}) exists! Enable auto_create_database or create it by useself" if !@auto_create_database
        # create new database as it doesn't exists
        @client.create_database(@docdb_database)
      end

      # initial operations for collection
      database_resource = @client.get_database_resource(@docdb_database)
      res = @client.find_collections_by_name(database_resource, @docdb_collection)
      if( res[:body]["_count"].to_i == 0 )
        raise "No collection (#{docdb_collection}) exists! Enable auto_create_collection or create it by useself" if !@auto_create_collection
        # create new collection as it doesn't exists
        if @partitioned_collection
          partition_key_paths = ["/#{@partition_key}"]
          @client.create_collection(database_resource,
                      @docdb_collection, partition_key_paths, @offer_throughput)
        else
          @client.create_collection(database_resource, @docdb_collection)
        end
      end
      @coll_resource = @client.get_collection_resource(database_resource, @docdb_collection)

    rescue Exception =>ex
      @logger.error("Documentdb output plugin's register Error: '#{ex}'")
      exit!
    end
  end # def register

  public
  def receive(event)
    document = event.to_hash()
    document['id'] =  SecureRandom.uuid

    ## Writing document to DocumentDB
    unique_doc_identifier = document['id']
    begin
      if @partitioned_collection
        @client.create_document(@coll_resource, unique_doc_identifier, document, @partition_key)
      else
        @client.create_document(@coll_resource, unique_doc_identifier, document)
      end
    rescue RestClient::ExceptionWithResponse => rcex
      exdict = JSON.parse(rcex.response)
      if exdict['code'] == 'Conflict'
        $logger.error("Duplicate Error: document #{unique_doc_identifier} already exists, data=>" + (document.to_json).to_s)
      else
        $logger.error("RestClient Error: '#{rcex.response}', data=>" + (document.to_json).to_s)
      end
    rescue => ex
      $logger.error("UnknownError: '#{ex}', uniqueid=>#{unique_doc_identifier}, data=>" + (document.to_json).to_s )
    end
  end # def event

end # class LogStash::Outputs::Documentdb
