Gem::Specification.new do |s|
  s.name = 'logstash-output-opentsdb_using_filter_metrics'
  s.version         = "2.0.2"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "This output allows you to pull metrics['count'] from metrics filter and ship them to opentsdb"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["eunkyung-kim"]
  s.homepage = 'https://github.com/eunkyungkim/logstash-output-opentsdb_using_filter_metrics'
  s.email = "paulina0206@gmail.com"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0.beta2", "< 3.0.0" if RUBY_PLATFORM == 'java'
  s.add_development_dependency "logstash-devutils", "~> 0.0", ">= 0.0.18"  if RUBY_PLATFORM == 'java'
end