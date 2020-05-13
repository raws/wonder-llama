# Wonder Llama

Wonder Llama is a [Zulip](https://zulipchat.com) API client for Ruby. It's simple to use, depends only on Ruby's standard library, and is well-tested.

It's called Wonder Llama because [LevelUp](https://www.thelevelup.com)'s Zulip bot, for which this library was built, is named Ralph.

## Usage

You'll need a [Zulip API key](https://zulipchat.com/api/rest).

```rb
require 'wonder_llama'

client = WonderLlama::Client.new(host: 'example.zulipchat.com',
  email: 'ralph@example.com', api_key: 's3cr3t')

client.get_all_users.each do |user|
  puts "#{user.id}: #{user.full_name} (#{user.email})"
end

client.send_message(type: 'stream', to: 'social', topic: 'greetings',
  content: 'hello world!')

client.send_message(type: 'private', to: 'ari@example.com',
  content: 'thanks for the accidental deployment :robot:')

client.stream_events do |event|
  if event.is_a?(WonderLlama::MessageEvent)
    message = event.message
    puts message.content
  end
end
```

Check out the `examples` directory for more.

## Contributing

Contributions are welcome!

To run the tests, install the development dependencies and use `bin/rspec`.

```sh
bundle install
bin/rspec
```

## License

MIT
