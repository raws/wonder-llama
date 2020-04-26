describe WonderLlama::HeartbeatEvent do
  let(:client) do
    WonderLlama::Client.new(api_key: 'test-api-key', email: 'test@example.com',
      host: 'test.example.com')
  end

  let(:event) { described_class.new(client: client, params: { 'id' => 1 }) }

  describe 'TYPE' do
    subject { described_class::TYPE }
    it { is_expected.to eq('heartbeat') }
  end

  describe '#heartbeat?' do
    subject { event.heartbeat? }
    it { is_expected.to eq(true) }
  end

  describe '#id' do
    subject { event.id }
    it { is_expected.to eq(1) }
  end

  describe '#type' do
    subject { event.type }
    it { is_expected.to eq(described_class::TYPE) }
  end
end
