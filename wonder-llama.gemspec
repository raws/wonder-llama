Gem::Specification.new do |gem|
  gem.name = 'wonder-llama'
  gem.version = '0.0.1'
  gem.license = 'MIT'
  gem.summary = 'Zulip API client'
  gem.authors = ['Ross Paffett']
  gem.email = 'ross@rosspaffett.com'
  gem.homepage = 'https://github.com/raws/wonder-llama'
  gem.files = Dir['lib/wonder_llama/*.rb'] << 'lib/wonder_llama.rb'

  gem.add_development_dependency 'rspec', '~> 3.9.0'
  gem.add_development_dependency 'webmock', '~> 3.8.3'
end
