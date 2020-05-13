require 'logger'

$LOAD_PATH.unshift(File.join(__dir__, '../lib'))
require 'wonder_llama'

class StreamEventsExample
  def initialize(api_key:, email:, host:)
    @client = WonderLlama::Client.new(api_key: api_key, email: email, host: host)
    @logger = Logger.new(STDOUT)
  end

  def run
    @logger.info("Streaming events as #{@client.email} on #{@client.host}...")

    @client.stream_events do |event|
      @logger.info(event.inspect)
    end
  end

  private

  def register_event_queue
    @event_queue = @client.register_event_queue
  end
end

require_relative 'load_credentials'
StreamEventsExample.new(api_key: $api_key, email: $email, host: $host).run
