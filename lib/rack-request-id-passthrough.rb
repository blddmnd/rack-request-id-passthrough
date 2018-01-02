require 'rack-request-id-passthrough/configuration'
require 'rack-request-id-passthrough/middleware/rack'
require 'rack-request-id-passthrough/middleware/sidekiq'
require 'rack-request-id-passthrough/net_http_header'

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

    def need_to_patch_headers?
      configuration.http_headers.any?
    end
  end
end

require 'rack-request-id-passthrough/rails' if defined? Rails::Railtie
require 'rack-request-id-passthrough/sidekiq' if defined? Sidekiq
