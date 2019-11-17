describe WonderLlama::Client do
  let(:client) do
    described_class.new(host: 'test.example.com', email: 'ralph@example.com',
      api_key: 'test-api-key')
  end

  describe '#send_message' do
    subject do
      client.send_message(content: 'Hello world!', to: 'greetings', topic: 'hello', type: 'stream')
    end

    context 'when the request succeeds' do
      before do
        stub_request(:post, 'https://test.example.com/api/v1/messages').
          with(body: { content: 'Hello world!', to: 'greetings', topic: 'hello', type: 'stream' }).
          to_return(body: JSON.generate(id: 1, msg: '', result: 'success'))
      end

      it 'returns a successful MessageResponse' do
        expect(subject).to be_success
        expect(subject.id).to eq(1)
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:post, 'https://test.example.com/api/v1/messages').
          with(body: { content: 'Hello world!', to: 'greetings', topic: 'hello', type: 'stream' }).
          to_return(body: JSON.generate(code: 'STREAM_DOES_NOT_EXIST',
            msg: 'Stream \'greetings\' does not exist', result: 'error', stream: 'greetings'))
      end

      it 'returns an unsuccessful MessageResponse' do
        expect(subject).not_to be_success
        expect(subject.id).to be_nil
      end
    end
  end
end
