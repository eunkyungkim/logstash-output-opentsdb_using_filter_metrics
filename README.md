[![Build Status](https://travis-ci.org/eunkyungkim/logstash-output-opentsdb_using_filter_metrics.svg?branch=master)](https://travis-ci.org/eunkyungkim/logstash-output-opentsdb_using_filter_metrics) [![Gem Version](https://badge.fury.io/rb/logstash-output-opentsdb_using_filter_metrics.svg)](https://badge.fury.io/rb/logstash-output-opentsdb_using_filter_metrics)

# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Usage
```
input {
  kafka {
    zk_connect => "diana-kafka-zookeeper1:2181,diana-kafka-zookeeper2:2181,diana-kafka-zookeeper3:2181"
    topic_id => "diana-put-metrics"
    group_id => "diana-put-metrics-consumer-group"
  }
}
filter {
  metrics {
    meter => [ "tag1|value1|tag2|value2" ]
    add_tag => "metric"
    ##### must be clear_interval = flush_interval
    clear_interval => 10
    flush_interval => 10
    remove_field => [ "@version",  "message" ]
  }
}
output {
  # Meter key of metrics filter will be tags.
  # Meter count value will be metric value.
  opentsdb_using_filter_metrics {
    host => "localhost"
    port => 4242
    workers => 4
    metric_name => "test.count.diana.access"
    tag_separator => "|"   # meter separator  
    host => "local-hostname" # additional tag
  }
}
```
## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
bin/plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-filter-awesome.gem
```
- Start Logstash and proceed to test the plugin

