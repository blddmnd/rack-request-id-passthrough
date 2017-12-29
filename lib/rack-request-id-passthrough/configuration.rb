module RackRequestIDPassthrough
  class Configuration
    attr_reader :rails_initialization, :sidekiq_initialization, :source_headers, :response_headers, :http_headers

    def initialize
      @rails_initialization   = true
      @sidekiq_initialization = true
      @source_headers   = %w(RING-REQUEST-ID)
      @response_headers = %w(RING-REQUEST-ID)
      @http_headers     = %w(RING-REQUEST-ID)
    end

    %w(rails_initialization sidekiq_initialization).each do |method|
      define_method("#{method}=") do |val|
        instance_variable_set("@#{method}", !!val)
      end
    end

    %w(source_headers response_headers http_headers).each do |method|
      define_method("#{method}=") do |val|
        instance_variable_set("@#{method}", Array(val))
      end
    end
  end
end
