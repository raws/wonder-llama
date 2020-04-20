module WonderLlama
  class Client
    BLOCKING_READ_TIMEOUT_SECONDS = 300
    DEFAULT_HTTP_CONNECTION_OPTIONS = { use_ssl: true }.freeze
    NON_BLOCKING_READ_TIMEOUT_SECONDS = 5

    attr_reader :api_key, :email, :host

    def initialize(api_key:, email:, host:)
      @api_key = api_key
      @email = email
      @host = host
      @base_url = "https://#{host}"
    end

    def get_events_from_event_queue(blocking: true, last_event_id:, queue_id:)
      read_timeout = blocking ? BLOCKING_READ_TIMEOUT_SECONDS : NON_BLOCKING_READ_TIMEOUT_SECONDS
      connection_options = { read_timeout: read_timeout }

      params = { dont_block: !blocking, last_event_id: last_event_id, queue_id: queue_id }
      response = get(path: '/api/v1/events', params: params, connection_options: connection_options)

      response['events'].map do |event_params|
        Event.new_of_type_inferred_from(event_params)
      end
    end

    def register_event_queue
      response = post(path: '/api/v1/register')

      EventQueue.new(client: self, id: response['queue_id'],
        last_event_id: response['last_event_id'])
    end

    def send_message(content:, to:, topic:, type:)
      params = { content: content, to: to, topic: topic, type: type }
      response = post(path: '/api/v1/messages', params: params)

      Message.new(content: content, id: response['id'], to: to, topic: topic, type: type)
    end

    def stream_events(&block)
      event_queue = register_event_queue

      loop do
        begin
          event_queue.events.each(&block)
        rescue BadEventQueueIdError
          event_queue = register_event_queue
        end
      end
    end

    private

    def get(path:, params: nil, connection_options: {})
      uri = URI("#{@base_url}#{path}")

      if params
        uri.query = URI.encode_www_form(params)
      end

      http_request = Net::HTTP::Get.new(uri)
      response(http_request: http_request, options: connection_options)
    end

    def post(path:, params: nil, connection_options: {})
      uri = URI("#{@base_url}#{path}")
      http_request = Net::HTTP::Post.new(uri)

      if params
        http_request.set_form_data(params)
      end

      response(http_request: http_request, options: connection_options)
    end

    def response(http_request:, options:)
      http_request.basic_auth(@email, @api_key)
      http_request['Accept'] = 'application/json'

      http = Net::HTTP.new(http_request.uri.host, http_request.uri.port)

      options = DEFAULT_HTTP_CONNECTION_OPTIONS.merge(options)
      options.each do |key, value|
        setter_method_name = :"#{key}="

        if http.respond_to?(setter_method_name)
          http.public_send(setter_method_name, value)
        end
      end

      http.start
      http_response = http.request(http_request)
      http.finish

      if http_response.is_a?(Net::HTTPUnauthorized)
        raise AuthorizationError
      end

      api_response = Response.new(http_response)

      if api_response.success?
        api_response
      else
        error = ZulipError.new_of_type_inferred_from(api_response.parsed_body)
        raise error
      end
    ensure
      if http.started?
        http.finish
      end
    end
  end
end
