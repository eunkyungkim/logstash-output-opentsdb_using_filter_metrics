# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "socket"

# This output allows you to pull metrics from your logs and ship them to
# opentsdb. Opentsdb is an open source tool for storing and graphing metrics.
#
class LogStash::Outputs::OpentsdbUsingFilterMetrics < LogStash::Outputs::Base
  config_name "opentsdb_using_filter_metrics"

  # Enable debugging.
  config :debug, :validate => :boolean, :default => false, :deprecated => "This setting was never used by this plugin. It will be removed soon."

  # The address of the opentsdb server.
  config :host, :validate => :string, :default => "localhost"

  # The port to connect on your graphite server.
  config :port, :validate => :number, :default => 4242

  # Metric name
  config :metric_name, :validate => :string, :required => true

  # tag seperator
  config :tag_separator, :validate => :string, :required => true

  config :hostname, :validate => :string, :default => Socket.gethostname


  def register
    connect
  end # def register

  def connect
    # TODO(sissel): Test error cases. Catch exceptions. Find fortune and glory.
    begin
      @socket = TCPSocket.new(@host, @port)
      @logger.info("Connected to opentsdb server")
    rescue Errno::ECONNREFUSED => e
      @logger.warn("Connection refused to opentsdb server, sleeping...",
                   :host => @host, :port => @port)
      sleep(2)
      retry
    end
  end # def connect

  public
  def receive(event)


    # Opentsdb message format: put metric timestamp value tagname=tagvalue tag2=value2\n

    # Catch exceptions like ECONNRESET and friends, reconnect on failure.

    event_hash = event.to_hash
    tags = Array.new

    event_hash.each do |h_key, h_value|
      tags = h_key.split(@tag_separator)
      if tags.length > 1
        metric_name = @metric_name
        metric_value = h_value["count"]
        tags << "host" << hostname

        begin
          name = metric_name
          value = metric_value

          # The first part of the message
          message = ['put',
                     event.sprintf(name),
                     event.sprintf("%{+%s}"),
                     event.sprintf(value),
          ].join(" ")

          # If we have have tags we need to add it to the message
          event_tags = []
          unless tags.nil?
            Hash[*tags.flatten].each do |tag_name,tag_value|
              # Interprete variables if neccesary
              real_tag_name = event.sprintf(tag_name)
              real_tag_value =  event.sprintf(tag_value)
              event_tags << [real_tag_name , real_tag_value ].join('=')
            end
            message+=' '+event_tags.join(' ')
          end

          # TODO(sissel): Test error cases. Catch exceptions. Find fortune and glory.
          tries = 3
          begin
            @socket.puts(message)
          rescue Errno::EPIPE, Errno::ECONNRESET => e
            sleep(1)
            tries -= 1
            if tries > 0
              connect
              retry
            else
              @logger.warn("Connection to opentsdb server died",
                           :exception => e, :host => @host, :port => @port, :query => message)
            end
          end

          # TODO(sissel): resend on failure
          # TODO(sissel): Make 'resend on failure' tunable; sometimes it's OK to
          # drop metrics.
        end # @metrics.each
      end # tags.length > 1
    end # event_hash.each


  end # def receive
end # class LogStash::Outputs::OpentsdbUsingFilterMetrics