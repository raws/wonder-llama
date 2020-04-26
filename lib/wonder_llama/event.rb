module WonderLlama
  class Event
    attr_reader :client, :params

    def initialize(client:, params:)
      @client = client
      @params = params.transform_keys(&:to_sym)
    end

    def [](key)
      @params[key]
    end

    def heartbeat?
      false
    end

    def id
      self[:id]
    end

    def message?
      false
    end

    def self.new_of_type_inferred_from(client:, params:)
      klass = case params['type'].downcase
        when HeartbeatEvent::TYPE then HeartbeatEvent
        when MessageEvent::TYPE then MessageEvent
        else self
        end

      klass.new(client: client, params: params)
    end

    def type
      self[:type]
    end
  end
end
