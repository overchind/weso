# weso

Ruby ***WE***b***SO***cket Client. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'weso'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:
```bash
gem install weso
```

## Usage

You can create an instance of the `Weso::Base::Client` class and configure required events with a public `connect` method on the `Weso::Base` module. Note, that this method creates a new instance every time. The functionality with valid client reconnection now in progress.

```ruby
client = Weso::Base.connect 'wss://test.com' do |c|
  c.on :open do
    puts("I've opened a new websocket connection!")
  end
  
  c.on :close do
    puts("I'll miss you! Connection is closed now.")
  end
  
  c.on :error do |error|
    puts("I'm sorry, but something went wrong. Lets check the error:")
    puts(error)
  end
end
```

If you need to configure encryption settings other than defaults, I advise you to review [`Weso::Base::SocketCreator`](./lib/weso/socket_creator.rb) class. In order to perform useful work with the client, you need to configure the `:message` event and not be shy to write first with `send_data` method:

```ruby
client.on :message do |message|
  puts(message.data)
end

client.send_data("Hello! How you doing?")
```

In case if you want to check the client connection status - `open?`, `closed?` and `handshaked?` are your best friends. And do not forget to close the connection when you finished your work:

```ruby
client.close
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/overchind/weso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/overchind/weso/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the weso project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/overchind/weso/blob/master/CODE_OF_CONDUCT.md).
