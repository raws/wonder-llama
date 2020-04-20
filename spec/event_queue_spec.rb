describe WonderLlama::EventQueue do
  let(:client) do
    WonderLlama::Client.new(api_key: 'test-api-key', email: 'test@example.com',
      host: 'test.example.com')
  end

  let(:event_queue) { described_class.new(client: client, id: '1517975029:0', last_event_id: 1) }

  describe '#client' do
    subject { event_queue.client }
    it { is_expected.to eq(client) }
  end

  describe '#events' do
    let(:first_expected_events) do
      [
        WonderLlama::HeartbeatEvent.new(id: 3),
        WonderLlama::MessageEvent.new(id: 4, message: 'cool chat'),
        WonderLlama::MessageEvent.new(id: 2, message: 'hello everyone!')
      ]
    end

    let(:second_expected_events) do
      [
        WonderLlama::HeartbeatEvent.new(id: 5),
        WonderLlama::MessageEvent.new(id: 6, message: 'it is indeed the coolest')
      ]
    end

    shared_examples 'returns arrays of events and keeps track of the last event' do |blocking|
      before do
        allow(client).to receive(:get_events_from_event_queue).
          with(blocking: blocking, last_event_id: 1, queue_id: '1517975029:0').
          and_return(first_expected_events)
        allow(client).to receive(:get_events_from_event_queue).
          with(blocking: blocking, last_event_id: 4, queue_id: '1517975029:0').
          and_return(second_expected_events)
      end

      it 'returns arrays of events and keeps track of the last event' do
        latest_events = event_queue.events(**args)
        expect(latest_events).to include_event(WonderLlama::MessageEvent).with(id: 2)
        expect(latest_events).to include_event(WonderLlama::HeartbeatEvent).with(id: 3)
        expect(latest_events).to include_event(WonderLlama::MessageEvent).with(id: 4)

        expect(event_queue.last_event_id).to eq(4)

        latest_events = event_queue.events(**args)
        expect(latest_events).to include_event(WonderLlama::HeartbeatEvent).with(id: 5)
        expect(latest_events).to include_event(WonderLlama::MessageEvent).with(id: 6)
      end
    end

    context 'without any arguments' do
      let(:args) { {} }
      include_examples 'returns arrays of events and keeps track of the last event', true
    end

    context 'when specifying blocking mode' do
      let(:args) { { blocking: true } }
      include_examples 'returns arrays of events and keeps track of the last event', true
    end

    context 'when specifying non-blocking mode' do
      let(:args) { { blocking: false } }
      include_examples 'returns arrays of events and keeps track of the last event', false
    end
  end

  describe '#id' do
    subject { event_queue.id }
    it { is_expected.to eq('1517975029:0') }
  end

  describe '#last_event_id' do
    subject { event_queue.last_event_id }
    it { is_expected.to eq(1) }
  end
end
