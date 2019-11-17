require_relative '../lib/wonder_llama'

require 'webmock/rspec'

support_files_pattern = File.join(File.dirname(__FILE__), 'support/**/*.rb')
Dir[support_files_pattern].each { |file| require(file) }
