module WonderLlama
  class Error < ::StandardError; end

  class AuthorizationError < Error; end

  class ZulipError < Error
    attr_reader :code

    def initialize(message, code:)
      super(message)
      @code = code
    end

    def self.new_of_type_inferred_from(error_response_body)
      code = error_response_body['code']
      message = error_response_body['msg']

      case code
      when BadEventQueueIdError::CODE
        queue_id = error_response_body['queue_id']
        BadEventQueueIdError.new(message, queue_id: queue_id)
      else
        new(message, code: code)
      end
    end
  end

  class BadEventQueueIdError < ZulipError
    CODE = 'BAD_EVENT_QUEUE_ID'

    attr_reader :queue_id

    def initialize(message, queue_id:)
      super(message, code: CODE)
      @queue_id = queue_id
    end
  end
end
