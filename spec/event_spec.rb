describe WonderLlama::Event do
  let(:event) { described_class.new('id' => 1, 'foo' => 'bar', baz: 'qux', 'type' => 'unknown') }

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

  describe '#id' do
    subject { event.id }
    it { is_expected.to eq(1) }
  end

  describe '.new_of_type_inferred_from' do
    subject { described_class.new_of_type_inferred_from(params) }

    let(:params) do
      { 'id' => 1 }
    end

    context 'with a heartbeat event' do
      before { params['type'] = WonderLlama::HeartbeatEvent::TYPE }
      it { is_expected.to be_an_instance_of(WonderLlama::HeartbeatEvent) }
    end

    context 'with a message event' do
      before { params['type'] = WonderLlama::MessageEvent::TYPE }
      it { is_expected.to be_an_instance_of(WonderLlama::MessageEvent) }
    end

    context 'with an unknown event type' do
      before { params['type'] = 'unknown' }

      it 'returns an Event with the expected type' do
        expect(subject).to be_an_instance_of(described_class)
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
