describe WonderLlama::HeartbeatEvent do
  let(:event) { described_class.new('id' => 1) }

  describe 'TYPE' do
    subject { described_class::TYPE }
    it { is_expected.to eq('heartbeat') }
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
