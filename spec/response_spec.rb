describe WonderLlama::Response do
  let(:response) { described_class.new(http_response) }
  it_behaves_like 'a response'
end
