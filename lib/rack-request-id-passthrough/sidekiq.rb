module RackRequestIDPassthrough
  class SidekiqMiddleware
    def call(worker_class, job, queue, redis_pool)
      if use_request_passthrough?
        job['capi_request_id'] = Thread.current[:request_id_passthrough]
      end

      yield
    end

    def use_request_passthrough?
      !!RackRequestIDPassthrough.configuration.sidekiq_initialization
    end
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add RackRequestIDPassthrough::SidekiqMiddleware
  end
end
