module RackRequestIDPassthrough
  class Railtie < Rails::Railtie
    initializer "request_passthrough.configure_rails_initialization" do
      if use_request_passthrough?
        insert_middleware
      end
    end

    def insert_middleware
      if defined? Rack::Runtime
        app.middleware.insert_after Rack::Runtime, RackRequestIDPassthrough::Middleware
      else
        app.middleware.use RackRequestIDPassthrough::Middleware
      end
    end

    def use_request_passthrough?
      !!RackRequestIDPassthrough.configuration.rails_initialization
    end

    def app
      Rails.application
    end
  end
end
