describe 'RackRequestIDPassthrough::Middleware::Rack' do
  let(:app)     { ->(env) { [200, {}, [env.to_yaml]] } }
  let(:stack)   { RackRequestIDPassthrough::Middleware::Rack.new app }
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
    RackRequestIDPassthrough.configuration.http_headers = %w[RING-REQUEST-ID REQUEST-ID]

    response = request.get '/', 'RING-REQUEST-ID' => 'firstheader', 'REQUEST-ID' => 'secondheader'
    expect(response.headers['RING-REQUEST-ID']).to eq('firstheader')
  end

  it 'should set a global constant containing the request id' do
    response = request.get '/'
    expect(Thread.current[:request_id_passthrough]).to eq(response.headers['RING-REQUEST-ID'])
  end
end
