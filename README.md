# Azure DocumentDB output plugin for Logstash

logstash-output-documentdb is a logstash plugin to output to Azure DocumentDB. [Logstash](https://www.elastic.co/products/logstash) is an open source, server-side data processing pipeline that ingests data from a multitude of sources simultaneously, transforms it, and then sends it to your favorite [destinations](https://www.elastic.co/products/logstash). [Azure DocumentDB](https://azure.microsoft.com/en-us/services/documentdb/) is a managed NoSQL database service provided by Microsoft Azure. It’s schemaless, natively support JSON, very easy-to-use, very fast, highly reliable, and enables rapid deployment, you name it.

## Installation

You can install this plugin using the Logstash "plugin" or "logstash-plugin" (for newer versions of Logstash) command:
```
bin/plugin install logstash-output-documentdb
# or 
bin/logstash-plugin install logstash-output-documentdb  (Newer versions of Logstash)
```
Please see [Logstash reference](https://www.elastic.co/guide/en/logstash/current/offline-plugins.html) for more information.

## Configuration

```
output {
    documentdb {
        docdb_endpoint => "https://<YOUR ACCOUNT>.documents.azure.com:443/"
        docdb_account_key => "<ACCOUNT KEY>"
        docdb_database => "<DATABASE NAME>"
        docdb_collection => "<COLLECTION NAME>"
        auto_create_database => true|false
        auto_create_collection => true|false
        partitioned_collection => true|false
        partition_key =>  "<PARTITIONED KEY NAME>"
        offer_throughput => <THROUGHPUT NUM>
    }
}
```

 * **docdb\_endpoint (required)** - Azure DocumentDB Account endpoint URI
 * **docdb\_account\_key (required)** - Azure DocumentDB Account key (master key). You must NOT set a read-only key
 * **docdb\_database (required)** - DocumentDB database nameb
 * **docdb\_collection (required)** - DocumentDB collection name
 * **auto\_create\_database (optional)** - Default:true. By default, DocumentDB database named **docdb\_database** will be automatically created if it does not exist
 * **auto\_create\_collection (optional)** - Default:true. By default, DocumentDB collection named **docdb\_collection** will be automatically created if it does not exist
 * **partitioned\_collection (optional)** - Default:false. Set true if you want to create and/or store records to partitioned collection. Set false for single-partition collection
 * **partition\_key (optional)** - Default:nil. Partition key must be specified for paritioned collection (partitioned\_collection set to be true)
 * **offer\_throughput (optional)** - Default:10100. Throughput for the collection expressed in units of 100 request units per second. This is only effective when you newly create a partitioned collection (ie. Both auto\_create\_collection and partitioned\_collection are set to be true )


## Tests

logstash-output-documentdb adds id attribute (UUID format) to in-coming events automatically and send them to DocumentDB. Here is an example configuration where Logstash's event source and destination are configured as Apache2 access log and DocumentDB respectively.

### Example Configuration
```
input {
    file {
        path => "/var/log/apache2/access.log"
        start_position => "beginning"
    }
}

filter {
    if [path] =~ "access" {
        mutate { replace => { "type" => "apache_access" } }
        grok {
            match => { "message" => "%{COMBINEDAPACHELOG}" }
        }
    }
    date {
        match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
}

output {
    documentdb {
        docdb_endpoint => "https://yoichikademo.documents.azure.com:443/"
        docdb_account_key => "EMwUa3EzsAtJ1qYfzwo9nQxxydofsXNm3xLh1SLffKkUHMFl80OZRZIVu4lxdKRKxkgVAj0c2mv9BZSyMN7tdg==(dummy)"
        docdb_database => "testdb"
        docdb_collection => "apache_access"
        auto_create_database => true
        auto_create_collection => true
    }
    # for debug
    stdout { codec => rubydebug }
}
```
You can find example configuration files in logstash-output-documentdb/examples.

### Run the plugin with the example configuration

Now you run logstash with the the example configuration like this:
```
# Test your logstash configuration before actually running the logstash
bin/logstash -f logstash-apache2-to-documentdb.conf  --configtest
# run
bin/logstash -f logstash-apache2-to-documentdb.conf
```

Here is an expected output for sample input (Apache2 access log):

<u>Apache2 access log</u>
```
124.211.152.166 - - [27/Dec/2016:02:12:28 +0000] "GET /test.html HTTP/1.1" 200 316 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"
```

<u>Output (rubydebug)</u>
```
{
        "message" => "124.211.152.166 - - [27/Dec/2016:02:12:28 +0000] \"GET /test.html HTTP/1.1\" 200 316 \"-\" \"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36\"",
       "@version" => "1",
     "@timestamp" => "2016-12-27T02:12:28.000Z",
           "path" => "/var/log/apache2/access.log",
           "host" => "yoichitest01",
           "type" => "apache_access",
       "clientip" => "124.211.152.166",
          "ident" => "-",
           "auth" => "-",
      "timestamp" => "27/Dec/2016:02:12:28 +0000",
           "verb" => "GET",
        "request" => "/test.html",
    "httpversion" => "1.1",
       "response" => "200",
          "bytes" => "316",
       "referrer" => "\"-\"",
          "agent" => "\"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36\"",
             "id" => "0cae1966-b7ab-4f32-8893-b4fabc7800ae"
}
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/yokawasa/logstash-output-documentdb.

