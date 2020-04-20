describe WonderLlama::MessageEvent do
  let(:event) do
    message_params = {
      content: 'Hello world!',
      id: 2,
      to: 'social',
      topic: 'greetings',
      type: 'stream'
    }

    described_class.new('id' => 1, 'message' => message_params)
  end

  describe 'TYPE' do
    subject { described_class::TYPE }
    it { is_expected.to eq('message') }
  end

  describe '#id' do
    subject { event.id }
    it { is_expected.to eq(1) }
  end

  describe '#message' do
    subject { event.message }

    it 'returns a message' do
      expect(subject.content).to eq('Hello world!')
      expect(subject.id).to eq(2)
      expect(subject.to).to eq('social')
      expect(subject.topic).to eq('greetings')
      expect(subject.type).to eq('stream')
    end
  end

  describe '#type' do
    subject { event.type }
    it { is_expected.to eq(described_class::TYPE) }
  end
end
