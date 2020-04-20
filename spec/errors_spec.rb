describe WonderLlama::BadEventQueueIdError do
  describe '#initialize' do
    subject { described_class.new('Bad event queue id: 1517975029:0', queue_id: '1517975029:0') }

    it 'provides access to details of the Zulip error response' do
      expect(subject.code).to eq('BAD_EVENT_QUEUE_ID')
      expect(subject.message).to eq('Bad event queue id: 1517975029:0')
      expect(subject.queue_id).to eq('1517975029:0')
    end
  end
end

describe WonderLlama::ZulipError do
  subject { described_class.new_of_type_inferred_from(error_response_body) }

  describe '.new_of_type_inferred_from' do
    context 'when the error code is BAD_EVENT_QUEUE_ID' do
      let(:error_response_body) do
        {
          'code' => 'BAD_EVENT_QUEUE_ID',
          'msg' => 'Bad event queue id: 1517975029:0',
          'queue_id' => '1517975029:0',
          'result' => 'error'
        }
      end

      it 'returns an instance of BadEventQueueIdError' do
        expect(subject).to be_instance_of(WonderLlama::BadEventQueueIdError)
        expect(subject.code).to eq('BAD_EVENT_QUEUE_ID')
        expect(subject.message).to eq('Bad event queue id: 1517975029:0')
        expect(subject.queue_id).to eq('1517975029:0')
      end
    end

    context 'when the error code is not recognized' do
      let(:error_response_body) do
        {
          'code' => 'OH_NO',
          'msg' => 'Something terrible has happened',
          'result' => 'error'
        }
      end

      it 'returns an instance of ZulipError' do
        expect(subject).to be_instance_of(WonderLlama::ZulipError)
        expect(subject.code).to eq('OH_NO')
        expect(subject.message).to eq('Something terrible has happened')
      end
    end
  end

  describe '#initialize' do
    subject { described_class.new('Something terrible has happened', code: 'OH_NO') }

    it 'provides access to details of the Zulip error response' do
      expect(subject.code).to eq('OH_NO')
      expect(subject.message).to eq('Something terrible has happened')
    end
  end
end
