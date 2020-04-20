module WonderLlama
  class EventQueue
    attr_reader :client, :id, :last_event_id

    def initialize(client:, id:, last_event_id:)
      @client = client
      @id = id
      @last_event_id = last_event_id
    end

    def events(blocking: true)
      latest_events = @client.get_events_from_event_queue(blocking: blocking,
        last_event_id: last_event_id, queue_id: id)
      @last_event_id = latest_events.map(&:id).max
      latest_events
    end
  end
end
