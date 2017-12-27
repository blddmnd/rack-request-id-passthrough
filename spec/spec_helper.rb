require 'simplecov'
SimpleCov.start

require 'rack-request-id-passthrough'
require 'rack/mock'
require 'webmock/rspec'

WebMock.disable_net_connect!
