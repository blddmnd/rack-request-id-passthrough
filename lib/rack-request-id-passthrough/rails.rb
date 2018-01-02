module RackRequestIDPassthrough
  class Railtie < Rails::Railtie
    initializer 'request_passthrough.configure_rails_initialization' do
      if RackRequestIDPassthrough.configuration.rails_initialization
        insert_middleware
      end
    end

    def insert_middleware
      if defined? Rack::Runtime
        app.middleware.insert_after Rack::Runtime, RackRequestIDPassthrough::Middleware::Rack
      else
        app.middleware.use RackRequestIDPassthrough::Middleware::Rack
      end
    end

    def app
      Rails.application
    end
  end
end
