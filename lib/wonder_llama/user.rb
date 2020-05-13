module WonderLlama
  class User
    EMBEDDED_BOT_TYPE = :embedded
    GENERIC_BOT_TYPE = :generic
    INCOMING_WEBHOOK_BOT_TYPE = :incoming_webhook
    OUTGOING_WEBHOOK_BOT_TYPE = :outgoing_webhook
    BOT_TYPES = {
      1 => GENERIC_BOT_TYPE,
      2 => INCOMING_WEBHOOK_BOT_TYPE,
      3 => OUTGOING_WEBHOOK_BOT_TYPE,
      4 => EMBEDDED_BOT_TYPE
    }.freeze

    attr_reader :client, :params

    def initialize(client:, params:)
      @client = client
      @params = params.transform_keys(&:to_sym).freeze
    end

    def ==(other)
      return false unless other.respond_to?(:client) && other.respond_to?(:params)
      other.client == client && other.params == params
    end
    alias_method :eql?, :==

    def [](key)
      params[key]
    end

    def active?
      !!params[:is_active]
    end

    def admin?
      !!params[:is_admin]
    end

    def avatar_url
      params[:avatar_url]
    end

    def bot?
      !!params[:is_bot]
    end

    def bot_type
      BOT_TYPES[params[:bot_type]] if params.key?(:bot_type)
    end

    def date_joined
      @date_joined ||= Time.parse(params[:date_joined]) if params.key?(:date_joined)
    rescue ArgumentError
      nil
    end

    def email
      params[:email]
    end

    def full_name
      params[:full_name]
    end

    def guest?
      !!params[:is_guest]
    end

    def hash
      @hash ||= client.hash + params.hash
    end

    def id
      params[:user_id]
    end

    def timezone
      params[:timezone]
    end
  end
end
