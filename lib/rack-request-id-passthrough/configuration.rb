module RackRequestIDPassthrough
  class Configuration
    attr_accessor :source_headers, :response_headers, :http_headers

    def initialize
      @source_headers   = %w(RING-REQUEST-ID)
      @response_headers = %w(RING-REQUEST-ID)
      @http_headers     = %w(RING-REQUEST-ID)
    end
  end
end
