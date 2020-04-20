module WonderLlama
  class MessageEvent < Event
    TYPE = 'message'

    def message
      @message ||= Message.new(self[:message])
    end

    def type
      TYPE
    end
  end
end
