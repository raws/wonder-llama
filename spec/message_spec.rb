describe WonderLlama::Message do
  let(:message) do
    message_params = {
      'content' => 'Hello world!',
      'id' => 1,
      'to' => 'social',
      'topic' => 'greetings',
      'type' => 'stream',
      'foo' => 'bar'
    }

    described_class.new(message_params)
  end

  describe '#[]' do
    subject { message[:foo] }
    it { is_expected.to eq('bar') }
  end

  describe '#content' do
    subject { message.content }
    it { is_expected.to eq('Hello world!') }
  end

  describe '#id' do
    subject { message.id }
    it { is_expected.to eq(1) }
  end

  describe '#to' do
    subject { message.to }
    it { is_expected.to eq('social') }
  end

  describe '#topic' do
    subject { message.topic }

    context 'when the message params include a topic key' do
      let(:message) { described_class.new('topic' => 'topic value') }
      it { is_expected.to eq('topic value') }
    end

    context 'when the message params include a subject key' do
      let(:message) { described_class.new('subject' => 'subject value') }
      it { is_expected.to eq('subject value') }
    end
  end

  describe '#type' do
    subject { message.type }
    it { is_expected.to eq('stream') }
  end
end
