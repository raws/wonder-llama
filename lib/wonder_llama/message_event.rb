module WonderLlama
  class MessageEvent < Event
    TYPE = 'message'

    def message
      @message ||= Message.new(client: client, params: self[:message])
    end

    def message?
      true
    end

    def type
      TYPE
    end
  end
end
