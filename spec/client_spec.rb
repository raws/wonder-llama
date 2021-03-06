describe WonderLlama::Client do
  shared_examples 'raises AuthorizationError' do
    it 'raises AuthorizationError' do
      expect { subject }.to raise_error(WonderLlama::AuthorizationError)
    end
  end

  shared_examples 'raises ZulipError' do |expected_message|
    it 'raises ZulipError' do
      expect { subject }.to raise_error(WonderLlama::ZulipError, expected_message)
    end
  end

  let(:client) do
    described_class.new(host: 'test.example.com', email: 'ralph@example.com',
      api_key: 'test-api-key')
  end

  describe 'BLOCKING_READ_TIMEOUT_SECONDS' do
    subject { described_class::BLOCKING_READ_TIMEOUT_SECONDS }
    it { is_expected.to eq(300) }
  end

  describe 'DEFAULT_HTTP_CONNECTION_OPTIONS' do
    subject { described_class::DEFAULT_HTTP_CONNECTION_OPTIONS }
    it { is_expected.to eq({ use_ssl: true }) }
  end

  describe 'NON_BLOCKING_READ_TIMEOUT_SECONDS' do
    subject { described_class::NON_BLOCKING_READ_TIMEOUT_SECONDS }
    it { is_expected.to eq(5) }
  end

  describe '#api_key' do
    subject { client.api_key }
    it { is_expected.to eq('test-api-key') }
  end

  describe '#email' do
    subject { client.email }
    it { is_expected.to eq('ralph@example.com') }
  end

  describe '#get_events_from_event_queue' do
    subject { client.get_events_from_event_queue(last_event_id: -1, queue_id: '1517975029:0') }

    context 'when the request succeeds' do
      before do
        response_body = {
          events: [
            {
              id: 0,
              type: 'message',
              message: {
                content: 'hello friends',
                id: 1234,
                subject: 'greetings',
                type: 'stream'
              }
            },
            {
              id: 1,
              type: 'heartbeat'
            },
            {
              id: 2,
              type: 'unknown'
            }
          ],
          msg: '',
          result: 'success'
        }

        stub_request(:get, 'https://test.example.com/api/v1/events').
          with(query: { dont_block: false, last_event_id: -1, queue_id: '1517975029:0'}).
          to_return(body: JSON.generate(response_body))
      end

      it 'returns an array of events' do
        expect(subject).to include_event(WonderLlama::MessageEvent).with(id: 0, client: client)
        expect(subject).to include_event(WonderLlama::HeartbeatEvent).with(id: 1, client: client)
        expect(subject).to include_event(WonderLlama::Event).with(id: 2,
          type: 'unknown', client: client)
      end
    end

    context 'when the Zulip server has garbage collected the event queue' do
      before do
        response_body = {
          code: 'BAD_EVENT_QUEUE_ID',
          msg: 'Bad event queue ID: 1517975029:0',
          queue_id: '1517975029:0',
          result: 'error'
        }

        stub_request(:get, 'https://test.example.com/api/v1/events').
          with(query: { dont_block: false, last_event_id: -1, queue_id: '1517975029:0' }).
          to_return(body: JSON.generate(response_body))
      end

      it 'raises BadEventQueueIdError' do
        expect { subject }.to raise_error(WonderLlama::BadEventQueueIdError,
          'Bad event queue ID: 1517975029:0')
      end
    end

    context 'when the Zulip server returns an unrecognized error' do
      before do
        response_body = {
          code: 'OH_NO',
          msg: 'Something terrible has happened',
          result: 'error'
        }

        stub_request(:get, 'https://test.example.com/api/v1/events').
          with(query: { dont_block: false, last_event_id: -1, queue_id: '1517975029:0' }).
          to_return(body: JSON.generate(response_body))
      end

      include_examples 'raises ZulipError', 'Something terrible has happened'
    end

    context 'when the API credentials are invalid' do
      before do
        stub_request(:get, 'https://test.example.com/api/v1/events').
          with(query: { dont_block: false, last_event_id: -1, queue_id: '1517975029:0' }).
          to_return(status: 401)
      end

      include_examples 'raises AuthorizationError'
    end
  end

  describe '#host' do
    subject { client.host }
    it { is_expected.to eq('test.example.com') }
  end

  describe '#register_event_queue' do
    subject { client.register_event_queue }

    context 'when the request succeeds' do
      before do
        response_body = {
          last_event_id: -1,
          msg: '',
          queue_id: '1517975029:0',
          result: 'success'
        }

        stub_request(:post, 'https://test.example.com/api/v1/register').
          to_return(body: JSON.generate(response_body))
      end

      it 'returns an event queue' do
        expect(subject.id).to eq('1517975029:0')
        expect(subject.last_event_id).to eq(-1)
      end
    end

    context 'when the Zulip server returns an error' do
      before do
        response_body = {
          last_event_id: nil,
          msg: 'Something terrible has happened',
          queue_id: nil,
          result: 'error'
        }

        stub_request(:post, 'https://test.example.com/api/v1/register').
          to_return(body: JSON.generate(response_body))
      end

      include_examples 'raises ZulipError', 'Something terrible has happened'
    end

    context 'when the API credentials are invalid' do
      before do
        stub_request(:post, 'https://test.example.com/api/v1/register').
          to_return(status: 401)
      end

      include_examples 'raises AuthorizationError'
    end
  end

  describe '#send_message' do
    context 'when sending a message to a stream' do
      context 'with a stream ID' do
        subject { client.send_message(content: 'Hello world!', to: 789, topic: 'hello') }

        context 'when the request succeeds' do
          before do
            response_body = {
              id: 4,
              msg: '',
              result: 'success'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello world!', to: 789, topic: 'hello', type: 'stream' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'returns a stream message' do
            expect(subject).to be_stream
            expect(subject.content).to eq('Hello world!')
            expect(subject.id).to eq(4)
            expect(subject.to).to eq(789)
            expect(subject.topic).to eq('hello')
          end
        end

        context 'when the Zulip server returns an error' do
          before do
            response_body = {
              code: 'STREAM_DOES_NOT_EXIST',
              msg: 'Stream 789 does not exist',
              result: 'error',
              stream: 789
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello world!', to: 789,
                topic: 'hello', type: 'stream' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'raises ZulipError' do
            expect { subject }.to raise_error(WonderLlama::ZulipError,
              'Stream 789 does not exist')
          end
        end

        context 'when the API credentials are invalid' do
          before do
            stub_request(:post, 'https://test.example.com/api/v1/messages').
              to_return(status: 401)
          end

          include_examples 'raises AuthorizationError'
        end
      end

      context 'with a stream name' do
        subject { client.send_message(content: 'Hello world!', to: 'greetings', topic: 'hello') }

        context 'when the request succeeds' do
          before do
            response_body = {
              id: 1,
              msg: '',
              result: 'success'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello world!', to: 'greetings',
                topic: 'hello', type: 'stream' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'returns a stream message' do
            expect(subject).to be_stream
            expect(subject.content).to eq('Hello world!')
            expect(subject.id).to eq(1)
            expect(subject.to).to eq('greetings')
            expect(subject.topic).to eq('hello')
          end
        end

        context 'when the Zulip server returns an error' do
          before do
            response_body = {
              code: 'STREAM_DOES_NOT_EXIST',
              msg: 'Stream \'greetings\' does not exist',
              result: 'error',
              stream: 'greetings'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello world!', to: 'greetings',
                topic: 'hello', type: 'stream' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'raises ZulipError' do
            expect { subject }.to raise_error(WonderLlama::ZulipError,
              'Stream \'greetings\' does not exist')
          end
        end

        context 'when the API credentials are invalid' do
          before do
            stub_request(:post, 'https://test.example.com/api/v1/messages').
              to_return(status: 401)
          end

          include_examples 'raises AuthorizationError'
        end
      end
    end

    context 'when sending a private message' do
      context 'with a list of user IDs' do
        subject { client.send_message(content: 'Hello, friends!', to: [123, 456]) }

        before do
          @json_encoded_to = JSON.generate([123, 456])
        end

        context 'when the request succeeds' do
          before do
            response_body = {
              id: 3,
              msg: '',
              result: 'success'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello, friends!', to: @json_encoded_to,
                topic: nil, type: 'private' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'returns a private message' do
            expect(subject).to be_private
            expect(subject.content).to eq('Hello, friends!')
            expect(subject.id).to eq(3)
            expect(subject.to).to match_array([123, 456])
            expect(subject.topic).to be_nil
          end
        end

        context 'when the Zulip server returns an error' do
          before do
            response_body = {
              code: 'BAD_REQUEST',
              msg: 'Invalid user ID 123',
              result: 'error'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello, friends!', to: @json_encoded_to,
                topic: nil, type: 'private' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'raises ZulipError' do
            expect { subject }.to raise_error(WonderLlama::ZulipError, 'Invalid user ID 123')
          end
        end

        context 'when the API credentials are invalid' do
          before do
            stub_request(:post, 'https://test.example.com/api/v1/messages').
              to_return(status: 401)
          end

          include_examples 'raises AuthorizationError'
        end
      end

      context 'with a list of email addresses' do
        subject do
          client.send_message(content: 'Hello, friends!',
            to: ['friend1@example.com', 'friend2@example.com'])
        end

        before do
          @json_encoded_to = JSON.generate(['friend1@example.com', 'friend2@example.com'])
        end

        context 'when the request succeeds' do
          before do
            response_body = {
              id: 2,
              msg: '',
              result: 'success'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello, friends!', to: @json_encoded_to,
                topic: nil, type: 'private' }).
              to_return(body: JSON.generate(response_body))
          end

          it 'returns a private message' do
            expect(subject).to be_private
            expect(subject.content).to eq('Hello, friends!')
            expect(subject.id).to eq(2)
            expect(subject.to).to match_array(['friend1@example.com', 'friend2@example.com'])
            expect(subject.topic).to be_nil
          end
        end

        context 'when the Zulip server returns an error' do
          before do
            response_body = {
              code: 'BAD_REQUEST',
              msg: 'Invalid email \'friend1@example.com\'',
              result: 'error'
            }

            stub_request(:post, 'https://test.example.com/api/v1/messages').
              with(body: { content: 'Hello, friends!', to: @json_encoded_to,
                topic: nil, type: 'private' }).
              to_return(body: JSON.generate(response_body))
          end

          include_examples 'raises ZulipError', 'Invalid email \'friend1@example.com\''
        end

        context 'when the API credentials are invalid' do
          before do
            stub_request(:post, 'https://test.example.com/api/v1/messages').
              to_return(status: 401)
          end

          include_examples 'raises AuthorizationError'
        end
      end
    end
  end

  describe '#stream_events' do
    before do
      # Return two groups of messages from an event queue, then garbage collect it
      first_event_queue = instance_double('WonderLlama::EventQueue', id: '1517975029:0')

      first_event_queue_messages = [
        [
          WonderLlama::HeartbeatEvent.new(client: client, params: { id: 0 }),
          WonderLlama::MessageEvent.new(client: client, params: { id: 1, message: 'hi everyone' })
        ], [
          WonderLlama::HeartbeatEvent.new(client: client, params: { id: 2 }),
          WonderLlama::HeartbeatEvent.new(client: client, params: { id: 3 })
        ]
      ]

      # Return two groups of messages, then simulate the event queue being garbage collected
      # by the Zulip server by raising BadEventQueueIdError
      allow(first_event_queue).to receive(:events) do
        first_event_queue_messages.shift ||
          raise(WonderLlama::BadEventQueueIdError.new('oh no', queue_id: '1517975029:0'))
      end

      # Return a message from a second event queue
      second_event_queue = instance_double('WonderLlama::EventQueue', id: '1517975029:1')

      second_event_queue_messages = [
        WonderLlama::MessageEvent.new(client: client, params: { id: 0, message: 'hello, friend!' }),
        :stop_streaming # Special token to break out of the event loop
      ]

      allow(second_event_queue).to receive(:events).and_return(second_event_queue_messages)

      allow(client).to receive(:register_event_queue).
        and_return(first_event_queue, second_event_queue)

      @expected_messages = first_event_queue_messages.flatten + second_event_queue_messages
      @expected_messages.pop # Don't expect the special :stop_streaming token to be yielded
    end

    it 'yields events and manages event queues' do
      actual_messages = []

      client.stream_events do |event|
        if event == :stop_streaming
          break
        else
          actual_messages << event
        end
      end

      expect(actual_messages).to eq(@expected_messages)
    end
  end

  describe '#users' do
    subject { client.users(**options) }
    let(:options) { Hash.new }

    shared_examples 'returns an array of users' do
      it 'returns an array of users' do
        expected_human = WonderLlama::User.new(client: client, params: @human_params)
        expected_bot = WonderLlama::User.new(client: client, params: @bot_params)
        expected_users = [expected_human, expected_bot]

        expect(subject).to match_array(expected_users)
      end
    end

    context 'when the request succeeds' do
      before do
        @human_params = {
          avatar_url: 'https://example.com/human.jpg',
          bot_type: nil,
          date_joined: Time.parse('2020-04-20T16:20:00-07:00').utc.iso8601,
          email: 'human@example.com',
          full_name: 'Human',
          is_active: false,
          is_admin: true,
          is_bot: false,
          is_guest: false,
          timezone: 'America/Los_Angeles',
          user_id: 1
        }

        @bot_params = {
          avatar_url: 'https://example.com/bot.jpg',
          bot_owner_id: 1,
          bot_type: 1,
          date_joined: Time.parse('2020-05-12T04:20:00-04:00').utc.iso8601,
          email: 'bot@example.com',
          full_name: 'Bot',
          is_active: true,
          is_admin: false,
          is_bot: true,
          is_guest: false,
          timezone: 'America/New_York',
          user_id: 2
        }

        @response_body = {
          members: [@human_params, @bot_params],
          msg: '',
          result: 'success'
        }
      end

      context 'with the default options' do
        before do
          stub_request(:get, 'https://test.example.com/api/v1/users').
            with(query: { client_gravatar: false, include_custom_profile_fields: false }).
            to_return(body: JSON.generate(@response_body))
        end

        include_examples 'returns an array of users'
      end

      context 'with the client_gravatar option' do
        before do
          options[:client_gravatar] = true
          stub_request(:get, 'https://test.example.com/api/v1/users').
            with(query: { client_gravatar: true, include_custom_profile_fields: false }).
            to_return(body: JSON.generate(@response_body))
        end

        include_examples 'returns an array of users'
      end

      context 'with the include_custom_profile_fields option' do
        before do
          options[:include_custom_profile_fields] = true
          stub_request(:get, 'https://test.example.com/api/v1/users').
            with(query: { client_gravatar: false, include_custom_profile_fields: true }).
            to_return(body: JSON.generate(@response_body))
        end

        include_examples 'returns an array of users'
      end
    end

    context 'when the Zulip server returns an unrecognized error' do
      before do
        response_body = {
          code: 'OH_NO',
          msg: 'Something terrible has happened',
          result: 'error'
        }

        stub_request(:get, 'https://test.example.com/api/v1/users').
          with(query: { client_gravatar: false, include_custom_profile_fields: false }).
          to_return(body: JSON.generate(response_body))
      end

      include_examples 'raises ZulipError', 'Something terrible has happened'
    end

    context 'when the API credentials are invalid' do
      before do
        stub_request(:get, 'https://test.example.com/api/v1/users').
          with(query: { client_gravatar: false, include_custom_profile_fields: false }).
          to_return(status: 401)
      end

      include_examples 'raises AuthorizationError'
    end
  end
end
