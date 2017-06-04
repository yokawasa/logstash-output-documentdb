# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/documentdb"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Documentdb do

  let(:docdb_endpoint) { 'https://<YOUR ACCOUNT>.documents.azure.com:443/' }
  let(:docdb_account_key) { '<ACCOUNT KEY>' }
  let(:docdb_database) { '<DATABASE NAME>' }
  let(:docdb_collection) { '<COLLECTION NAME>' }
  let(:auto_create_database) { true }
  let(:auto_create_collection) { true }

  let(:docdb_config) {
    { 
      "docdb_endpoint" => docdb_endpoint, 
      "docdb_account_key" => docdb_account_key,
      "docdb_database" => docdb_database,
      "docdb_collection" => docdb_collection,
      "auto_create_database" => auto_create_database,
      "auto_create_collection" => auto_create_collection,
    }
  }

  let(:docdb_output) { LogStash::Outputs::Documentdb.new(docdb_config) }

  before do
    docdb_output.register
  end 

  it "Should successfully send the event to documentdb" do
    properties = { "a" => 1, "b" => 2, "c" => 3 }
    event =  LogStash::Event.new(properties) 
    expect {docdb_output.receive(event)}.to_not raise_error
  end

end
