require 'rack-request-id-passthrough/configuration'
require 'rack/request-id-passthrough'

module RackRequestIDPassthrough
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration
    end
  end
end
