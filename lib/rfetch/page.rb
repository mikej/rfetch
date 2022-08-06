# frozen_string_literal: true

require "nokogiri"

module RFetch
  # Provides access to the title and description for a fetched page
  class Page
    def initialize(content)
      @content = content
    end

    def title
      @title ||= find_title
    end

    def description
      @description ||= find_description
    end

    def page
      @page ||= Nokogiri::HTML(@content)
    end

    private

      def find_title
        # look for meta titles then
        # try head>title first then fallback and try more relaxed title path if no matches
        # some sites e.g. YouTube seem to have a <title> outside of the <head>
        content_attr_of('meta[property="og:title"]') ||
          content_of("head>title") ||
          content_of("title")
      end

      def find_description
        # look for description in various meta tags
        content_attr_of('meta[property="og:description"]') ||
          content_attr_of('meta[name="twitter:description"]') ||
          content_attr_of('meta[name="description"]')
      end

      def content_of(expr)
        element = page.at_css(expr)
        element.content if element
      end

      def content_attr_of(expr)
        element = page.at_css(expr)
        element["content"] if element
      end
  end
end
