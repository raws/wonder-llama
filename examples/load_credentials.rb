required_environment_variables = %w(ZULIP_API_KEY ZULIP_EMAIL ZULIP_HOST)

unless required_environment_variables.all? { |key| ENV.key?(key) }
  warn "Please set #{required_environment_variables.join(', ')}"
  exit 1
end

$api_key = ENV['ZULIP_API_KEY']
$email = ENV['ZULIP_EMAIL']
$host = ENV['ZULIP_HOST']
