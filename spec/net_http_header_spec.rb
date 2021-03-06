describe 'Net::HTTPHeader' do
  let(:app)     { ->(env) { [200, {}, [env.to_yaml]] } }
  let(:stack)   { RackRequestIDPassthrough::Middleware::Rack.new app }
  let(:request) { Rack::MockRequest.new stack }
  let(:url)     { 'http://ring.com' }

  context 'with http_headers configuration' do
    it 'should append request id to outgoing headers' do
      response = request.get('/')

      stub = stub_request(:get, url)
             .with(headers: { 'Accept' => '*/*',
                              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                              'User-Agent' => 'Ruby',
                              'Ring-Request-Id' => response.headers['Ring-Request-Id'] })

      Net::HTTP.get(URI.parse(url))
      expect(stub).to have_been_requested
    end
  end

  context 'without http_headers configuration' do
    it 'should not append request id to outgoing headers' do
      RackRequestIDPassthrough.configuration.http_headers = nil

      request.get('/')
      stub = stub_request(:get, url)
             .with { |request| !request.headers.include?('Ring-Request-Id') }

      Net::HTTP.get(URI.parse(url))
      expect(stub).to have_been_requested
    end
  end
end
