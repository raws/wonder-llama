module WonderLlama
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def [](key)
      parsed_body[key]
    end

    def result
      self['result']
    end

    def success?
      @http_response.code.to_i == 200 && result == 'success'
    end

    private

    def parsed_body
      @parsed_body ||= begin
        JSON.parse(@http_response.body)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
