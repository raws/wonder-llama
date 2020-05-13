describe WonderLlama::User do
  shared_examples 'user equality' do
    context 'when their clients match' do
      context 'and their params match' do
        let(:other) { described_class.new(client: client, params: params) }
        it { is_expected.to eq(true) }
      end

      context 'and their params do not match' do
        let(:other) { described_class.new(client: client, params: {}) }
        it { is_expected.to eq(false) }
      end
    end

    context 'when their clients do not match' do
      let(:other_client) do
        WonderLlama::Client.new(api_key: '0th3r', email: 'other@example.com',
          host: 'test.example.com')
      end

      context 'and their params match' do
        let(:other) { described_class.new(client: other_client, params: params) }
        it { is_expected.to eq(false) }
      end

      context 'and their params do not match' do
        let(:other) { described_class.new(client: other_client, params: {}) }
        it { is_expected.to eq(false) }
      end
    end

    context 'when the other object is not a user' do
      let(:other) { :not_a_user }
      it { is_expected.to eq(false) }
    end
  end

  let(:user) { described_class.new(client: client, params: params) }

  let(:client) do
    WonderLlama::Client.new(api_key: 's3cr3t', email: 'test@example.com', host: 'test.example.com')
  end

  let(:params) do
    {
      avatar_url: 'https://example.com/human.jpg',
      bot_type: nil,
      date_joined: Time.parse('2020-04-20T16:20:00Z').iso8601,
      email: 'human@example.com',
      full_name: 'Human',
      is_active: true,
      is_admin: true,
      is_bot: false,
      is_guest: false,
      timezone: 'America/Los_Angeles',
      user_id: 1
    }
  end

  describe 'BOT_TYPES' do
    subject { described_class::BOT_TYPES }

    it 'maps the expected bot types' do
      expect(subject).to eq({
        1 => described_class::GENERIC_BOT_TYPE,
        2 => described_class::INCOMING_WEBHOOK_BOT_TYPE,
        3 => described_class::OUTGOING_WEBHOOK_BOT_TYPE,
        4 => described_class::EMBEDDED_BOT_TYPE
      })
    end

    it { is_expected.to be_frozen }
  end

  describe 'EMBEDDED_BOT_TYPE' do
    subject { described_class::EMBEDDED_BOT_TYPE }
    it { is_expected.to eq(:embedded) }
  end

  describe 'GENERIC_BOT_TYPE' do
    subject { described_class::GENERIC_BOT_TYPE }
    it { is_expected.to eq(:generic) }
  end

  describe 'INCOMING_WEBHOOK_BOT_TYPE' do
    subject { described_class::INCOMING_WEBHOOK_BOT_TYPE }
    it { is_expected.to eq(:incoming_webhook) }
  end

  describe 'OUTGOING_WEBHOOK_BOT_TYPE' do
    subject { described_class::OUTGOING_WEBHOOK_BOT_TYPE }
    it { is_expected.to eq(:outgoing_webhook) }
  end

  describe '==' do
    subject { user == other }
    include_examples 'user equality'
  end

  describe '#[]' do
    subject { user[:arbitrary_key] }
    before { params[:arbitrary_key] = 'foo' }
    it { is_expected.to eq('foo') }
  end

  describe '#active?' do
    subject { user.active? }

    context 'when the user is active' do
      before { params[:is_active] = true }
      it { is_expected.to eq(true) }
    end

    context 'when the user is not active' do
      before { params[:is_active] = false }
      it { is_expected.to eq(false) }
    end

    context 'when the param is absent' do
      before { params.delete(:is_active) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#admin?' do
    subject { user.admin? }

    context 'when the user is an admin' do
      before { params[:is_admin] = true }
      it { is_expected.to eq(true) }
    end

    context 'when the user is not an admin' do
      before { params[:is_admin] = false }
      it { is_expected.to eq(false) }
    end

    context 'when the param is absent' do
      before { params.delete(:is_admin) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#avatar_url' do
    subject { user.avatar_url }

    context 'when the param is present' do
      before { params[:avatar_url] = 'https://example.com/human.jpg' }
      it { is_expected.to eq('https://example.com/human.jpg') }
    end

    context 'when the param is absent' do
      before { params.delete(:avatar_url) }
      it { is_expected.to be_nil }
    end
  end

  describe '#bot?' do
    subject { user.bot? }

    context 'when the user is a human' do
      before { params[:is_bot] = false }
      it { is_expected.to eq(false) }
    end

    context 'when the user is a bot' do
      before { params[:is_bot] = true }
      it { is_expected.to eq(true) }
    end

    context 'when the param is absent' do
      before { params.delete(:is_bot) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#bot_type' do
    subject { user.bot_type }

    context 'when the user is a human' do
      before { params.delete(:bot_type) }
      it { is_expected.to be_nil }
    end

    context 'when the user is an embedded bot' do
      before { params[:bot_type] = 4 }
      it { is_expected.to eq(described_class::EMBEDDED_BOT_TYPE) }
    end

    context 'when the user is a generic bot' do
      before { params[:bot_type] = 1 }
      it { is_expected.to eq(described_class::GENERIC_BOT_TYPE) }
    end

    context 'when the user is an incoming webhook bot' do
      before { params[:bot_type] = 2 }
      it { is_expected.to eq(described_class::INCOMING_WEBHOOK_BOT_TYPE) }
    end

    context 'when the user is an outgoing webhook bot' do
      before { params[:bot_type] = 3 }
      it { is_expected.to eq(described_class::OUTGOING_WEBHOOK_BOT_TYPE) }
    end

    context 'when the param is absent' do
      before { params.delete(:bot_type) }
      it { is_expected.to be_nil }
    end
  end

  describe '#client' do
    subject { user.client }
    it { is_expected.to eq(client) }
  end

  describe '#date_joined' do
    subject { user.date_joined }

    context 'when the param is present' do
      before { params[:date_joined] = Time.parse('2020-04-20T16:20:00Z').iso8601 }
      it { is_expected.to eq(Time.new(2020, 4, 20, 16, 20, 0, '+00:00')) }
    end

    context 'when the param is an invalid timestamp' do
      before { params[:date_joined] = 'invalid' }
      it { is_expected.to be_nil }
    end

    context 'when the param is absent' do
      before { params.delete(:date_joined) }
      it { is_expected.to be_nil }
    end
  end

  describe '#email' do
    subject { user.email }

    context 'when the param is present' do
      before { params[:email] = 'human@example.com' }
      it { is_expected.to eq('human@example.com') }
    end

    context 'when the param is absent' do
      before { params.delete(:email) }
      it { is_expected.to be_nil }
    end
  end

  describe '#eql?' do
    subject { user.eql?(other) }
    include_examples 'user equality'
  end

  describe '#full_name' do
    subject { user.full_name }

    context 'when the param is present' do
      before { params[:full_name] = 'Human' }
      it { is_expected.to eq('Human') }
    end

    context 'when the param is absent' do
      before { params.delete(:full_name) }
      it { is_expected.to be_nil }
    end
  end

  describe '#guest?' do
    subject { user.guest? }

    context 'when the user is a guest' do
      before { params[:is_guest] = true }
      it { is_expected.to eq(true) }
    end

    context 'when the user is not a guest' do
      before { params[:is_guest] = false }
      it { is_expected.to eq(false) }
    end

    context 'when the param is absent' do
      before { params.delete(:is_guest) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#hash' do
    subject { user.hash }
    it { is_expected.to eq(client.hash + params.hash) }
  end

  describe '#id' do
    subject { user.id }

    context 'when the param is present' do
      before { params[:user_id] = 1 }
      it { is_expected.to eq(1) }
    end

    context 'when the param is absent' do
      before { params.delete(:user_id) }
      it { is_expected.to be_nil }
    end
  end

  describe '#params' do
    subject { user.params }
    it { is_expected.to eq(params) }
    it { is_expected.to be_frozen }
  end

  describe '#timezone' do
    subject { user.timezone }

    context 'when the param is present' do
      before { params[:timezone] = 'America/Los_Angeles' }
      it { is_expected.to eq('America/Los_Angeles') }
    end

    context 'when the param is absent' do
      before { params.delete(:timezone) }
      it { is_expected.to be_nil }
    end
  end
end
