require 'yaml'
require 'pry'
require 'net/http'
require 'uri'

describe 'RackRequestIDPassthrough::Middleware' do
  let(:app)     { ->(env) { [200, {}, [env.to_yaml]] } }
  let(:stack)   { RackRequestIDPassthrough::Middleware.new app }
  let(:request) { Rack::MockRequest.new stack }

  it 'should generate random request IDs' do
    first_response = request.get('/')
    second_response = request.get('/')
    expect(first_response.headers['RING-REQUEST-ID']).not_to eq(second_response.headers['RING-REQUEST-ID'])
  end

  it 'should return the request ID in the response headers' do
    response = request.get '/'
    expect(response.headers['RING-REQUEST-ID']).not_to be_empty
  end

  it 'should persist and existing request ID' do
    response = request.get '/', 'RING-REQUEST-ID' => 'cloudflaretestid'
    expect(response.headers['RING-REQUEST-ID']).to eq('cloudflaretestid')
  end

  it 'should ignore the casing of the headers' do
    response = request.get '/', 'ring-REQUEST-id' => 'cloudflaretestid'
    expect(response.headers['RING-REQUEST-ID']).to eq('cloudflaretestid')
  end

  it 'should ignore the http prepended onto the headers' do
    response = request.get '/', 'HTTP-RING-REQUEST-ID' => 'cloudflaretestid'
    expect(response.headers['RING-REQUEST-ID']).to eq('cloudflaretestid')
  end

  it 'should treat _ and - the same' do
    response = request.get '/', 'RING_REQUEST_ID' => 'cloudflaretestid'
    expect(response.headers['RING-REQUEST-ID']).to eq('cloudflaretestid')
  end

  it 'should choose which id to persist in order' do
    RackRequestIDPassthrough.configuration.http_headers = %w(RING-REQUEST-ID REQUEST-ID)

    response = request.get '/', 'RING-REQUEST-ID' => 'firstheader', 'REQUEST-ID' => 'secondheader'
    expect(response.headers['RING-REQUEST-ID']).to eq('firstheader')

    RackRequestIDPassthrough.configuration.http_headers = %w(RING-REQUEST-ID)
  end

  it 'should set a global constant containing the request id' do
    response = request.get '/'
    expect(Thread.current[:add_request_id_to_http]).to be_truthy
    expect(Thread.current[:request_id_passthrough]).to eq(response.headers['RING-REQUEST-ID'])
  end
end

describe 'Net::HTTPHeader' do
  let(:app)     { ->(env) { [200, {}, [env.to_yaml]] } }
  let(:stack)   { RackRequestIDPassthrough::Middleware.new app }
  let(:request) { Rack::MockRequest.new stack }

  context 'with http_headers configuration' do
    it 'should append request id to outgoing headers' do
      response = request.get('/')
      stub = stub_request(:get, 'http://example.com/').
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Host' => 'example.com', 'User-Agent' => 'Ruby',
                          'Ring-Request-Id' => response.headers['Ring-Request-Id'] })
      Net::HTTP.get_response(URI.parse('http://example.com'))
      expect(stub).to have_been_requested
      WebMock.reset!
    end
  end

  context 'without http_headers configuration' do
    around do |example|
      RackRequestIDPassthrough.configuration.http_headers = []
      example.run
      RackRequestIDPassthrough.configuration.http_headers = %w(RING-REQUEST-ID)
    end

    it 'should not append request id to outgoing headers' do
      request.get('/')
      stub = stub_request(:get, 'http://example.com/')
      stub_request(:get, 'example.com').with { |request| !request.headers.include?('Ring-Request-Id') }
      Net::HTTP.get_response(URI.parse('http://example.com'))
      expect(stub).to have_been_requested
    end
  end
end

describe 'RackRequestIDPassthrough::Configuration' do
  it 'returns default params' do
    expect(RackRequestIDPassthrough.configuration.rails_initialization).to   be_truthy
    expect(RackRequestIDPassthrough.configuration.sidekiq_initialization).to be_truthy

    expect(RackRequestIDPassthrough.configuration.source_headers).to   eq(%w(RING-REQUEST-ID))
    expect(RackRequestIDPassthrough.configuration.response_headers).to eq(%w(RING-REQUEST-ID))
    expect(RackRequestIDPassthrough.configuration.http_headers).to     eq(%w(RING-REQUEST-ID))
  end

  it 'can be configured with block' do
    RackRequestIDPassthrough.configure do |config|
      config.source_headers = %w(ONE TWO)
      config.http_headers   = []
    end

    expect(RackRequestIDPassthrough.configuration.source_headers).to   eq(%w(ONE TWO))
    expect(RackRequestIDPassthrough.configuration.response_headers).to eq(%w(RING-REQUEST-ID))
    expect(RackRequestIDPassthrough.configuration.http_headers).to     eq([])
  end

  it 'can be configured with setters' do
    RackRequestIDPassthrough.configuration.source_headers = []
    expect(RackRequestIDPassthrough.configuration.source_headers).to eq([])
  end
end
