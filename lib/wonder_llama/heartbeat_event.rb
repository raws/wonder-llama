module WonderLlama
  class HeartbeatEvent < Event
    TYPE = 'heartbeat'

    def type
      TYPE
    end
  end
end
