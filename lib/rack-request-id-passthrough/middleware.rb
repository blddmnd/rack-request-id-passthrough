require 'securerandom'
require 'net/http'

module RackRequestIDPassthrough
  class Middleware
    def initialize(app)
      @app = app
      @headers = RackRequestIDPassthrough.configuration.source_headers
      @outgoing_header = RackRequestIDPassthrough.configuration.response_headers
    end

    def call(env)
      Thread.current[:request_id_passthrough] = determine_request_id(env)
      Thread.current[:add_request_id_to_http] = need_to_patch_headers?

      status, headers, response = @app.call(env)

      populate_headers(headers)
      [status, headers, response]
    end

    private

    def determine_request_id(env)
      request_id = SecureRandom.uuid
      matches = {}

      env.each do |k, v|
        @headers.find do |header|
          matches[header] = v if same_header?(header, k)
        end
      end

      @headers.find do |header_name|
        request_id = matches[header_name] if matches[header_name]
      end

      request_id
    end

    def same_header?(header_name, env_key)
      h = header_name.upcase.gsub('_','-').gsub('HTTP-', '')
      k = env_key.upcase.gsub('_','-').gsub('HTTP-', '')
      h == k
    end

    def populate_headers(headers)
      @outgoing_header.each do |header_name|
        headers[header_name] = Thread.current[:request_id_passthrough]
      end
    end

    def need_to_patch_headers?
      !(RackRequestIDPassthrough.configuration.http_headers.nil? || RackRequestIDPassthrough.configuration.http_headers.empty?)
    end
  end
end

module Net::HTTPHeader
  alias original_initialize_http_header initialize_http_header

  def initialize_http_header(initheader)
    if Thread.current[:add_request_id_to_http] && Thread.current[:request_id_passthrough]
      initheader ||= {}
      RackRequestIDPassthrough.configuration.http_headers.each do |header|
        initheader[header] = Thread.current[:request_id_passthrough]
      end
    end
    original_initialize_http_header(initheader)
  end
end
