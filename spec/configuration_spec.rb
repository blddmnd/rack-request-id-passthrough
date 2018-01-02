describe 'RackRequestIDPassthrough.configuration' do
  it 'returns default params' do
    expect(RackRequestIDPassthrough.configuration.rails_initialization).to   be_truthy
    expect(RackRequestIDPassthrough.configuration.sidekiq_initialization).to be_truthy

    expect(RackRequestIDPassthrough.configuration.http_headers).to     eq(%w[RING-REQUEST-ID])
    expect(RackRequestIDPassthrough.configuration.source_headers).to   eq(%w[RING-REQUEST-ID])
    expect(RackRequestIDPassthrough.configuration.response_headers).to eq(%w[RING-REQUEST-ID])

    expect(RackRequestIDPassthrough.configuration.sidekiq_request_key).to eq('ring_request_id')
  end

  it 'can be configured with block' do
    RackRequestIDPassthrough.configure do |config|
      config.source_headers         = %w[ONE TWO]
      config.http_headers           = []
      config.response_headers       = nil
      config.rails_initialization   = nil
      config.sidekiq_initialization = 'true'
      config.sidekiq_request_key    = 'app_request_id'
    end

    expect(RackRequestIDPassthrough.configuration.source_headers).to   eq(%w[ONE TWO])
    expect(RackRequestIDPassthrough.configuration.response_headers).to eq([])
    expect(RackRequestIDPassthrough.configuration.http_headers).to     eq([])
    expect(RackRequestIDPassthrough.configuration.rails_initialization).to   be_falsey
    expect(RackRequestIDPassthrough.configuration.sidekiq_initialization).to be_truthy
    expect(RackRequestIDPassthrough.configuration.sidekiq_request_key).to eq('app_request_id')
  end

  it 'can be configured with setters' do
    RackRequestIDPassthrough.configuration.source_headers = []
    RackRequestIDPassthrough.configuration.sidekiq_request_key = nil

    expect(RackRequestIDPassthrough.configuration.source_headers).to eq([])
    expect(RackRequestIDPassthrough.configuration.sidekiq_request_key).to eq('ring_request_id')
  end
end

describe 'RackRequestIDPassthrough.reset!' do
  it 'should reset configuration' do
    RackRequestIDPassthrough.configure do |config|
      config.source_headers = %w[ONE TWO]
      config.http_headers   = []
    end

    RackRequestIDPassthrough.reset!

    expect(RackRequestIDPassthrough.configuration.source_headers).to eq(%w[RING-REQUEST-ID])
    expect(RackRequestIDPassthrough.configuration.http_headers).to   eq(%w[RING-REQUEST-ID])
  end
end

describe 'RackRequestIDPassthrough.need_to_patch_headers?' do
  it 'should return TRUE if http header is exists' do
    RackRequestIDPassthrough.configuration.http_headers = %w[ONE TWO]
    expect(RackRequestIDPassthrough.need_to_patch_headers?).to be_truthy
  end

  it 'should return FALSE if http header is blank' do
    RackRequestIDPassthrough.configuration.http_headers = nil
    expect(RackRequestIDPassthrough.need_to_patch_headers?).to be_falsey
  end
end
