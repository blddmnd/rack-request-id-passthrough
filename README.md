# RackRequestIDPassthrough Middleware

Rack middleware which will take incoming headers (such as request id) and ensure that they are passed along to outgoing http requests.
This can be used to track a request throughout your architecture by ensuring that all networks calls will recieve the same request id as the request originator.  An example of such an envrionment would be as follows:

![Diagram](https://raw.githubusercontent.com/blddmnd/rack-request-id-passthrough/master/diagram.png "Diagram")

Based on https://github.com/careerbuilder/rack-request-id-passthrough

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-request-id-passthrough'
```

And then execute:
```bash
bundle install
```

Or install it yourself as:
```bash
gem install rack-request-id-passthrough
```

#### Sinatra (or any rack based stack)

```ruby
# config.ru

class MyApp < Sinatra::Base
  use RackRequestIDPassthrough::Middleware::Rack
end
```

#### Rails
By default, middleware will be added automatically, but if you want you can disable `rails_initialization` configuration and add middleware by yourself.

```ruby
# ./config/application.rb

module MyApp
  class Application < Rails::Application
    # ...
    # Warning! Make sure that you insert this middleware early so that you can capture all relevant network calls
    config.middleware.insert_after Rack::Runtime, RackRequestIDPassthrough::Middleware::Rack
  end
end
```

#### Sidekiq
By default, middleware will be added automatically, but if you want you can disable `sidekiq_initialization` configuration and add middleware by yourself.

```ruby
# ./initializers/sidekiq.rb

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add RackRequestIDPassthrough::Middleware::Sidekiq::Client
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add RackRequestIDPassthrough::Middleware::Sidekiq::Server
  end
end
```

## Configuration Example

If you want to change default configuration you use configuration block:
```ruby
# ./config/initializers/rack-request-id-passthrough.rb

RackRequestIDPassthrough.configure do |config|
  # Insert rails middleware automatically
  config.rails_initialization   = true

  # Insert sidekiq middleware automatically
  config.sidekiq_initialization = true

  # The key into the sidekiq hash where we will store request ID
  config.sidekiq_request_key = 'ring_request_id'

  # An array of headers to look for incoming request id values
  config.source_headers   = %w[RING-REQUEST-ID]

  # An array of headers which will be appended to all responses
  config.response_headers = %w[RING-REQUEST-ID]

  # An array of http headers that will be appended to all outgoing http calls, if you don't want to append then set this to []
  config.http_headers     = %w[RING-REQUEST-ID]
end
```

Or you can use special methods to set some single parameter:
```ruby
RackRequestIDPassthrough.configuration.source_headers   = %w[RING-REQUEST-ID REQUEST-HEADER]
RackRequestIDPassthrough.configuration.response_headers = %w[RING-RESPONSE]
RackRequestIDPassthrough.configuration.http_headers     = %w[RING-OUTGOING]
```

So in the example above our gem would check the HTTP headers `RING-REQUEST-ID` and `REQUEST-HEADER` for a value (in that order). If it found one it would add it `Thread.current[:request_id_passthrough]` for usage. It would also add an HTTP header called `RING-OUTGOING` to all http requests going thru net/http that contains the request id.
