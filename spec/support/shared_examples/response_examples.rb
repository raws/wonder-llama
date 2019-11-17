shared_examples 'a response' do
  describe '#[]' do
    subject { response['foo'] }

    context 'when the body is valid JSON' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: '{"foo":"bar"}') }
      it { is_expected.to eq('bar') }
    end

    context 'when the body is not valid JSON' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: 'invalid') }
      it { is_expected.to be_nil }
    end
  end

  describe '#result' do
    subject { response.result }

    context 'when the body includes a result key' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: '{"result":"success"}') }
      it { is_expected.to eq('success') }
    end

    context 'when the body does not include a result key' do
      let(:http_response) { instance_double('Net::HTTPResponse', body: '{"foo":"bar"}') }
      it { is_expected.to be_nil }
    end
  end

  describe '#success?' do
    subject { response.success? }

    context 'when the HTTP response code is 200 OK' do
      context 'and the body indicates success' do
        let(:http_response) do
          instance_double('Net::HTTPResponse', code: 200, body: '{"result":"success"}')
        end

        it { is_expected.to eq(true) }
      end

      context 'and the body indicates an error' do
        let(:http_response) do
          instance_double('Net::HTTPResponse', code: 200, body: '{"result":"error"}')
        end

        it { is_expected.to eq(false) }
      end
    end

    context 'when the HTTP response code is not 200 OK' do
      context 'and the body indicates success' do
        let(:http_response) do
          instance_double('Net::HTTPResponse', code: 400, body: '{"result":"success"}')
        end

        it { is_expected.to eq(false) }
      end

      context 'and the body indicates an error' do
        let(:http_response) do
          instance_double('Net::HTTPResponse', code: 400, body: '{"result":"error"}')
        end

        it { is_expected.to eq(false) }
      end
    end
  end
end
