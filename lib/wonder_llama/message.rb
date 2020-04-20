module WonderLlama
  class Message
    def initialize(params)
      @params = params.transform_keys(&:to_sym)
    end

    def [](key)
      @params[key]
    end

    def content
      self[:content]
    end

    def id
      self[:id]
    end

    def to
      self[:to]
    end

    def topic
      self[:topic]
    end

    def type
      self[:type]
    end
  end
end
