module WonderLlama
  class HeartbeatEvent < Event
    TYPE = 'heartbeat'

    def heartbeat?
      true
    end

    def type
      TYPE
    end
  end
end
