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

  describe 'PRIVATE_TYPE' do
    subject { described_class::PRIVATE_TYPE }
    it { is_expected.to eq('private') }
    it { is_expected.to be_frozen }
  end

  describe 'STREAM_TYPE' do
    subject { described_class::STREAM_TYPE }
    it { is_expected.to eq('stream') }
    it { is_expected.to be_frozen }
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

  describe '#private?' do
    subject { message.private? }

    context 'with a private message' do
      before { params['type'] = described_class::PRIVATE_TYPE }
      it { is_expected.to eq(true) }
    end

    context 'with a stream message' do
      before { params['type'] = described_class::STREAM_TYPE }
      it { is_expected.to eq(false) }
    end
  end

  describe '#reply' do
    context 'with a stream message' do
      before do
        allow(client).to receive(:send_message)

        message.reply('hey there')
      end

      it 'replies to the stream' do
        expect(client).to have_received(:send_message).
          with(content: 'hey there', to: 'social', topic: 'greetings').once
      end
    end

    context 'with a private message' do
      before do
        params['to'] = ['friend1@example.com', 'friend2@example.com']
        params['type'] = described_class::PRIVATE_TYPE
        params.delete('topic')

        allow(client).to receive(:send_message)

        message.reply('hey there')
      end

      it 'replies to the private message thread' do
        expect(client).to have_received(:send_message).
          with(content: 'hey there', to: ['friend1@example.com', 'friend2@example.com'],
            topic: nil).once
      end
    end
  end

  describe '#stream?' do
    subject { message.stream? }

    context 'with a stream message' do
      before { params['type'] = described_class::STREAM_TYPE }
      it { is_expected.to eq(true) }
    end

    context 'with a private message' do
      before { params['type'] = described_class::PRIVATE_TYPE }
      it { is_expected.to eq(false) }
    end
  end

  describe '#to' do
    subject { message.to }

    context 'when the message params include a stream ID' do
      before do
        params.delete('to')
        params['stream_id'] = 75283
      end

      it { is_expected.to eq(75283) }
    end

    context 'when the message params include a stream name' do
      before do
        params.delete('stream_id')
        params['to'] = 'social'
      end

      it { is_expected.to eq('social') }
    end
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
