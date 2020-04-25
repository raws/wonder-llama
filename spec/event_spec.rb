describe WonderLlama::Event do
  let(:client) do
    WonderLlama::Client.new(api_key: 'test-api-key', email: 'test@example.com',
      host: 'test.example.com')
  end

  let(:event) do
    described_class.new(client: client, params: params)
  end

  let(:params) do
    { 'id' => 1, 'foo' => 'bar', baz: 'qux', 'type' => 'unknown' }
  end

  describe '#[]' do
    context 'when the params include a string key' do
      subject { event[:foo] }
      it { is_expected.to eq('bar') }
    end

    context 'when the params include a symbol key' do
      subject { event[:baz] }
      it { is_expected.to eq('qux') }
    end
  end

  describe '#client' do
    subject { event.client }
    it { is_expected.to eq(client) }
  end

  describe '#id' do
    subject { event.id }
    it { is_expected.to eq(1) }
  end

  describe '.new_of_type_inferred_from' do
    subject { described_class.new_of_type_inferred_from(client: client, params: params) }

    let(:params) do
      { 'id' => 1 }
    end

    context 'with a heartbeat event' do
      before { params['type'] = WonderLlama::HeartbeatEvent::TYPE }

      it { is_expected.to be_an_instance_of(WonderLlama::HeartbeatEvent) }

      it 'references the expected client' do
        expect(subject.client).to eq(client)
      end
    end

    context 'with a message event' do
      before { params['type'] = WonderLlama::MessageEvent::TYPE }

      it { is_expected.to be_an_instance_of(WonderLlama::MessageEvent) }

      it 'references the expected client' do
        expect(subject.client).to eq(client)
      end
    end

    context 'with an unknown event type' do
      before { params['type'] = 'unknown' }

      it 'returns an Event with the expected client and type' do
        expect(subject).to be_an_instance_of(described_class)
        expect(subject.client).to eq(client)
        expect(subject.type).to eq('unknown')
      end
    end
  end

  describe '#params' do
    subject { event.params }
    it { is_expected.to eq(id: 1, foo: 'bar', baz: 'qux', type: 'unknown') }
  end

  describe '#type' do
    subject { event.type }
    it { is_expected.to eq('unknown') }
  end
end
