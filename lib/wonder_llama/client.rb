module WonderLlama
  class Client
    def initialize(api_key:, email:, host:)
      @base_url = "https://#{host}"
      @email = email
      @api_key = api_key
    end

    def send_message(content:, to:, topic:, type:)
      params = { content: content, to: to, topic: topic, type: type }
      response = post(path: '/api/v1/messages', params: params)
      MessageResponse.new(response)
    end

    private

    def post(path:, params:)
      uri = URI("#{@base_url}#{path}")

      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@email, @api_key)
      request['Accept'] = 'application/json'
      request.set_form_data(params)

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end
  end
end
