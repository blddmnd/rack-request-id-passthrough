module RackRequestIDPassthrough
  class Configuration
    attr_accessor :rails_initialization, :sidekiq_initialization, :source_headers, :response_headers, :http_headers

    def initialize
      @rails_initialization   = true
      @sidekiq_initialization = true
      @source_headers   = %w(RING-REQUEST-ID)
      @response_headers = %w(RING-REQUEST-ID)
      @http_headers     = %w(RING-REQUEST-ID)
    end
  end
end
