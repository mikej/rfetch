# frozen_string_literal: true

require_relative "rfetch/version"
require_relative "rfetch/helpers"
require_relative "rfetch/page"

require "set"
require "faraday"

# Main module for RFetch
module RFetch
  REDIRECT_CODES = Set.new [301, 302, 303, 307, 308]

  Result = Struct.new(:url, :status_code, :content_type, :body) do
    def to_page
      raise "Media type #{content_type} can't be converted to a Page" unless media_type == "text/html"

      Page.new(body)
    end

    def media_type
      content_type.split(/;\s*/).first
    end
  end

  # used for non 2xx responses to requests
  class RequestError < StandardError
    attr_reader :status_code, :reason

    def initialize(status_code, reason)
      @status_code = status_code
      @reason = reason
      super "#{@status_code} #{@reason}"
    end
  end

  def self.get(url_requested)
    conn = Faraday::Connection.new

    url, response = following_redirects(url_requested) do |url|
      conn.get(url) { |req| req.options.timeout = 5 }
    end

    raise RequestError.new(response.status, response.reason_phrase) unless response.success?

    Result.new(url, response.status, response.headers["content-type"], response.body)
  end

  private_class_method def self.following_redirects(url)
    seen = []

    loop do
      response = yield url
      seen << url

      return [url, response] unless REDIRECT_CODES.include?(response.status)

      redirect = build_redirect(url, response)

      raise "Redirect loop back to #{redirect}" if seen.include?(redirect)

      url = redirect
    end
  end

  private_class_method def self.build_redirect(url, response)
    redirect = response.headers["location"]

    return redirect unless redirect.start_with? "/"

    # handle Location header with path only
    url = URI(url)
    url.path = redirect
    url.to_s
  end
end
