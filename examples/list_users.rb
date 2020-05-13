$LOAD_PATH.unshift(File.join(__dir__, '../lib'))
require 'wonder_llama'

class ListUsersExample
  def initialize(api_key:, email:, host:)
    @client = WonderLlama::Client.new(api_key: api_key, email: email, host: host)
  end

  def run
    puts "Listing users as #{@client.email} on #{@client.host}..."

    users.each do |user|
      puts "##{user.id}: #{user.full_name} (#{user.email})"
    end
  end

  private

  def users
    @client.users.sort_by(&:id)
  end
end

require_relative 'load_credentials'
ListUsersExample.new(api_key: $api_key, email: $email, host: $host).run
