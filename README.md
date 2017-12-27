# Rack::RequestIDPassthrough

Rack middleware which will take incoming headers (such as request id) and ensure that they are passed along to outgoing http requests.
This can be used to track a request throughout your architecture by ensuring that all networks calls will recieve the same request id as the request originator.  An example of such an envrionment would be as follows:

![Diagram](https://raw.githubusercontent.com/usbsnowcrash/rack-request-id-passthrough/master/diagram.png "Diagram")

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
  use Rack::RequestIDPassthrough
end
```

#### Rails

```ruby
# ./config/application.rb

module MyApp
  class Application < Rails::Application
    # ...
    # Warning! Make sure that you insert this middleware early so that you can capture all relevant network calls
    config.middleware.insert_after Rack::Runtime, Rack::RequestIDPassthrough
  end
end
```

## Configuration Example

If you want to change default configuration you use configuration block:
```ruby
# ./config/initializers/rack-request-id-passthrough.rb

RackRequestIDPassthrough.configure do |config|
  # List of source headers to look for request ids in
  config.source_headers   = %w(RING-REQUEST-ID)

  # Controls the response headers sent back to the browser
  config.response_headers = %w(RING-REQUEST-ID)

  # Name of http headers that will be appended to all outgoing http calls
  config.http_headers     = %w(RING-REQUEST-ID)
end
```

Or you can use special methods to set some single parameter:
```ruby
RackRequestIDPassthrough.configuration.source_headers   = %w(RING-REQUEST-ID REQUEST-HEADER)
RackRequestIDPassthrough.configuration.response_headers = %w(RING-RESPONSE)
RackRequestIDPassthrough.configuration.http_headers     = %w(RING-OUTGOING)
```

There are three main configuration options:
- source_headers: An array of headers to look for incoming request id values
- outgoing_headers: An array of headers which will be appended to all responses
- http_headers: An array of http headers that will be appended to all outgoing http calls, if you don't want to append then set this to []

So in the example above ridp gem would check the HTTP headers `RING-REQUEST-ID` and `REQUEST-HEADER` for a value (in that order). If it found one it would add it `Thread.current[:request_id_passthrough]` for usage. It would also add an HTTP header called `RING-OUTGOING` to all http requests going thru net/http that contains the request id.
