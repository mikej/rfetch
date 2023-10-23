# frozen_string_literal: true

require_relative "rfetch/version"
require_relative "rfetch/helpers"
require_relative "rfetch/page"
require_relative "rfetch/non_html_page"

require "set"
require "faraday"
require "faraday/httpclient"

# Main module for RFetch
module RFetch
  REDIRECT_CODES = Set.new [301, 302, 303, 307, 308]
  TEMPORARY_REDIRECT_CODES = Set.new [302, 307]

  Result = Struct.new(:url, :status_code, :content_type, :body) do
    def to_page
      Page.from(self)
    end

    def media_type
      content_type.split(/;\s*/).first
    end

    def inspect
      body_preview_size = 20

      "#<#{self.class.name} url=\"#{url}\" status_code=#{status_code} " \
        "content_type=\"#{content_type}\" body=\"#{body[...body_preview_size]}\">"
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

  def self.get(url_requested, options = {})
    url, response = following_redirects(url_requested) do |url|
      connection.get(url) do |req|
        req.options.timeout = options[:timeout] || 10
        req.headers[:accept] = "text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8"
      end
    end

    raise RequestError.new(response.status, response.reason_phrase) unless response.success?

    Result.new(url, response.status, response.headers["content-type"], response.body)
  end

  def self.connection=(connection)
    @connection = connection
  end

  def self.connection
    @connection ||= Faraday.new { |c| c.adapter(:httpclient) }
  end

  private_class_method def self.following_redirects(url)
    seen = []
    result_url = url
    been_through_temporary_redirect = false

    loop do
      response = yield url
      seen << url

      return [result_url, response] unless redirect?(response)

      redirect = build_redirect(url, response)

      raise "Redirect loop back to #{redirect}" if seen.include?(redirect)

      been_through_temporary_redirect = true if temporary_redirect?(response)

      url = redirect
      result_url = url unless been_through_temporary_redirect
    end
  end

  private_class_method def self.redirect?(response)
    REDIRECT_CODES.include?(response.status)
  end

  private_class_method def self.temporary_redirect?(response)
    TEMPORARY_REDIRECT_CODES.include?(response.status)
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
