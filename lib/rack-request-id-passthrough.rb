require 'rack-request-id-passthrough/configuration'
require 'rack-request-id-passthrough/middleware'

module RackRequestIDPassthrough
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration
    end

    def reset!
      @configuration = Configuration.new
    end
  end
end

require "rack-request-id-passthrough/rails" if defined? Rails::Railtie
require "rack-request-id-passthrough/sidekiq" if defined? Sidekiq
