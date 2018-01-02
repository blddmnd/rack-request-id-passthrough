describe 'RackRequestIDPassthrough::Middleware::Sidekiq::Client' do
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add RackRequestIDPassthrough::Middleware::Sidekiq::Client
    end
  end

  class TestWorker
    include Sidekiq::Worker

    def perform; end
  end

  it 'sets request id into the job hash' do
    RackRequestIDPassthrough.configuration.sidekiq_request_key = 'ring_id'
    Thread.current[:request_id_passthrough] = '654321'

    TestWorker.perform_async

    job = TestWorker.jobs.first
    expect(job['ring_id']).to eq('654321')
  end
end


describe 'RackRequestIDPassthrough::Middleware::Sidekiq::Server' do
  describe '#call' do
    let(:middleware) { RackRequestIDPassthrough::Middleware::Sidekiq::Server.new }

    it 'sets request_id_passthrough from the job' do
      RackRequestIDPassthrough.configuration.sidekiq_request_key = 'ring_id'

      middleware.call(nil, { 'ring_id' => '123456' }, nil) { nil }
      expect(Thread.current[:request_id_passthrough]).to eq('123456')
    end
  end
end
