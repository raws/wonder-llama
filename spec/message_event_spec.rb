describe WonderLlama::MessageEvent do
  let(:client) do
    WonderLlama::Client.new(api_key: 'test-api-key', email: 'test@example.com',
      host: 'test.example.com')
  end

  let(:event) { described_class.new(client: client, params: params) }

  let(:params) do
    {
      'id' => 1,
      'message' => {
        'content' => 'Hello world!',
        'id' => 2,
        'to' => 'social',
        'topic' => 'greetings',
        'type' => 'stream'
      },
      'type' => 'message'
    }
  end

  describe 'TYPE' do
    subject { described_class::TYPE }
    it { is_expected.to eq('message') }
  end

  describe '#client' do
    subject { event.client }
    it { is_expected.to eq(client) }
  end

  describe '#id' do
    subject { event.id }
    it { is_expected.to eq(1) }
  end

  describe '#message' do
    subject { event.message }

    it 'returns a message' do
      expect(subject.client).to eq(client)
      expect(subject.content).to eq('Hello world!')
      expect(subject.id).to eq(2)
      expect(subject.to).to eq('social')
      expect(subject.topic).to eq('greetings')
      expect(subject.type).to eq('stream')
    end
  end

  describe '#message?' do
    subject { event.message? }
    it { is_expected.to eq(true) }
  end

  describe '#params' do
    subject { event.params }
    it { is_expected.to eq(params.transform_keys(&:to_sym)) }
  end

  describe '#type' do
    subject { event.type }
    it { is_expected.to eq(described_class::TYPE) }
  end
end
