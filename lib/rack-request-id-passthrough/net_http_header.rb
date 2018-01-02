require 'net/http'

module Net::HTTPHeader
  alias original_initialize_http_header initialize_http_header

  def initialize_http_header(initheader)
    if RackRequestIDPassthrough.need_to_patch_headers? && Thread.current[:request_id_passthrough]
      initheader ||= {}
      RackRequestIDPassthrough.configuration.http_headers.each do |header|
        initheader[header] = Thread.current[:request_id_passthrough]
      end
    end
    original_initialize_http_header(initheader)
  end
end
