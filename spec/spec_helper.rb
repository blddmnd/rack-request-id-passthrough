require 'simplecov'
SimpleCov.start

require 'rack-request-id-passthrough'
require 'rack/mock'
require 'webmock/rspec'
require 'sidekiq/testing'

WebMock.disable_net_connect!

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before do
    Thread.current[:request_id_passthrough] = nil
    RackRequestIDPassthrough.reset!
  end
end
