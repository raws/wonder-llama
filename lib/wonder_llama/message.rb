module WonderLlama
  class Message
    PRIVATE_TYPE = 'private'.freeze
    STREAM_TYPE = 'stream'.freeze

    attr_reader :client, :params

    def initialize(client:, params:)
      @client = client
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

    def private?
      type == PRIVATE_TYPE
    end

    def stream?
      type == STREAM_TYPE
    end

    def to
      self[:to]
    end

    def topic
      self[:topic] || self[:subject]
    end

    def type
      self[:type]
    end
  end
end
