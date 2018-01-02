if RackRequestIDPassthrough.configuration.sidekiq_initialization
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add RackRequestIDPassthrough::Middleware::Sidekiq::Client
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add RackRequestIDPassthrough::Middleware::Sidekiq::Server
    end
  end
end
