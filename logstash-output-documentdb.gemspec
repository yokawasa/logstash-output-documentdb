Gem::Specification.new do |s|
  s.name = 'logstash-output-documentdb'
  s.version    =  File.read("VERSION").strip
  s.authors = ["Yoichi Kawasaki"]
  s.email = "yoichi.kawasaki@outlook.com"
  s.summary = %q{Store events into Azure DocumentDB}
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.homepage = "http://github.com/yokawasa/logstash-output-documentdb"
  s.licenses = ["Apache License (2.0)"]
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT', 'VERSION']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "rest-client", "~> 0"
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency "logstash-codec-plain", "~> 0"
  s.add_development_dependency "logstash-devutils", "~> 0"
end
