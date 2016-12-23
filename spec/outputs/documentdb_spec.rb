# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/documentdb"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Documentdb do

  let(:docdb_endpoint) { 'https://yoichikademo1.documents.azure.com:443/' }
  let(:docdb_account_key) { 'EMwUa3EzsAtJ1qYfzwo9nQ3KudofsXNm3xLh1SLffKkUHMFl80OZRZIVu4lxdKRKxkgVAj0c2mv9BZSyMN7tdg==' }
  let(:docdb_database) { 'BENCH02' }
  let(:docdb_collection) { 'single-par-coll' }
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

  describe "#recieve" do
    it "Should successfully send the event to documentdb" do
      properties = { "a" => 1, "b" => 2, "c" => 3 }
      event =  LogStash::Event.new(properties) 
      expect {docdb_output.receive(event)}.to_not raise_error
    end
  end

end
