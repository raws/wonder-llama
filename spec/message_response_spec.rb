describe WonderLlama::MessageResponse do
  let(:response) { described_class.new(http_response) }

  it_behaves_like 'a response'

  describe '#id' do
    subject { response.id }

    context 'when the body includes an id key' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: '{"id":1}') }
      it { is_expected.to eq(1) }
    end

    context 'when the body does not include an id key' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: '{"foo":"bar"}') }
      it { is_expected.to be_nil }
    end
  end
end
