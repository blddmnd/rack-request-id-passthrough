module RackRequestIDPassthrough
  module Middleware
    module Sidekiq
      class Client
        def call(worker_class, job, queue, redis_pool)
          job[RackRequestIDPassthrough.configuration.sidekiq_request_key] = Thread.current[:request_id_passthrough]

          yield
        end
      end

      class Server
        def call(worker_instance, msg, queue)
          Thread.current[:request_id_passthrough] = msg[RackRequestIDPassthrough.configuration.sidekiq_request_key]

          yield
        end
      end
    end
  end
end
