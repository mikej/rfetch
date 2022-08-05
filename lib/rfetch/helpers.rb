# frozen_string_literal: true

require "faraday"

module RFetch
  module Helpers
    POSSIBLE_PROTOCOLS  =  %w[https http]

    def self.ensure_protocol(possible_url)
      return possible_url if possible_url.nil? || possible_url.start_with?(/[a-z]+\:\/\//i)

      conn = Faraday::Connection.new
      protocol_to_add = POSSIBLE_PROTOCOLS.find do |protocol|
        to_try = "#{protocol}://#{possible_url}"
        conn.head(to_try) { |req| req.options.timeout = 5 }
      rescue Faraday::ConnectionFailed, Faraday::SSLError, Faraday::TimeoutError
        next
      rescue URI::InvalidURIError
        raise "invalid URL #{possible_url}"
      end

      if protocol_to_add
        "#{protocol_to_add}://#{possible_url}"
      else
        raise "couldn't find protocol for #{possible_url}"
      end
    end
  end
end
