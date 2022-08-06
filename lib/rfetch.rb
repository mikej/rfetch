# frozen_string_literal: true

require_relative "rfetch/version"
require_relative "rfetch/helpers"
require_relative "rfetch/page"

require "set"
require "faraday"

module RFetch
  REDIRECT_CODES  = Set.new [301, 302, 303, 307, 308]

  Result = Struct.new(:status_code, :content_type, :body) do
    def to_page
      if content_type == "text/html"
        Page.new(body)
      else
        raise "content of type #{content_type} can't be converted to a Page"
      end
    end
  end

  def self.get(url_requested)
    seen = []
    resp = nil

    conn = Faraday::Connection.new
    url = url_requested

    loop do
      resp = conn.get(url) { |req| req.options.timeout = 5 }
      seen << url

      break unless REDIRECT_CODES.include?(resp.status)

      redirect = resp.headers["location"]
      # handle Location header with path only
      if redirect.start_with? "/"
        url = URI(url)
        url.path = redirect
        redirect = url.to_s
      end

      raise "Redirect loop back to #{redirect}" if seen.include?(redirect)

      puts "Following redirect to #{redirect}"
      url = redirect
    end

    Result.new(resp.status, resp.headers["content-type"], resp.body)
  end
end
