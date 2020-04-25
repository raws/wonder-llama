describe WonderLlama::Message do
  let(:client) do
    WonderLlama::Client.new(api_key: 'test-api-key', email: 'test@example.com',
      host: 'test.example.com')
  end

  let(:message) { described_class.new(client: client, params: params) }

  let(:params) do
    {
      'content' => 'Hello world!',
      'id' => 1,
      'to' => 'social',
      'topic' => 'greetings',
      'type' => 'stream',
      'foo' => 'bar'
    }
  end

  describe '#[]' do
    subject { message[:foo] }
    it { is_expected.to eq('bar') }
  end

  describe '#client' do
    subject { message.client }
    it { is_expected.to eq(client) }
  end

  describe '#content' do
    subject { message.content }
    it { is_expected.to eq('Hello world!') }
  end

  describe '#id' do
    subject { message.id }
    it { is_expected.to eq(1) }
  end

  describe '#params' do
    subject { message.params }
    it { is_expected.to eq(params.transform_keys(&:to_sym)) }
  end

  describe '#to' do
    subject { message.to }
    it { is_expected.to eq('social') }
  end

  describe '#topic' do
    subject { message.topic }

    context 'when the message params include a topic key' do
      before do
        params.delete('subject')
        params['topic'] = 'fun topic'
      end

      it { is_expected.to eq('fun topic') }
    end

    context 'when the message params include a subject key' do
      before do
        params.delete('topic')
        params['subject'] = 'fun subject'
      end

      it { is_expected.to eq('fun subject') }
    end
  end

  describe '#type' do
    subject { message.type }
    it { is_expected.to eq('stream') }
  end
end
