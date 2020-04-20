require 'logger'

$:.unshift File.join(__dir__, '../lib')
require 'wonder_llama'

class StreamEventsExample
  def initialize(api_key:, email:, host:)
    @client = WonderLlama::Client.new(api_key: api_key, email: email, host: host)
    @logger = Logger.new(STDOUT)
  end

  def run
    @logger.info("Streaming events as #{@client.email} on #{@client.host}")

    @client.stream_events do |event|
      @logger.info(event.inspect)
    end
  end

  private

  def register_event_queue
    @event_queue = @client.register_event_queue
  end
end

required_environment_variables = %w(ZULIP_API_KEY ZULIP_EMAIL ZULIP_HOST)

unless required_environment_variables.all? { |key| ENV.key?(key) }
  $stderr.puts "Please set #{required_environment_variables.join(', ')}"
  exit 1
end

api_key = ENV['ZULIP_API_KEY']
email = ENV['ZULIP_EMAIL']
host = ENV['ZULIP_HOST']

StreamEventsExample.new(api_key: api_key, email: email, host: host).run
