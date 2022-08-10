# frozen_string_literal: true

RSpec.describe RFetch::Page do
  describe "#title" do
    pending "extracts the title from the page"
    pending "extracts the title from the page even if it is outside the head"
    pending "prioritises a title in meta og:title"
  end

  describe "#description" do
    pending "extracts the description from meta description"
    pending "extracts the description from meta twitter:description"
    pending "prioritises a description in meta og:description"
  end

  describe "#meta_content" do
    pending "returns the content from a meta tag"
    pending "returns the content from a meta tag identified by a specified attribute"
    pending "returns nil if the specified meta tag is not found"
  end

  describe "from" do
    pending "returns a Page for a result with media type of text/html"
    pending "returns a NonHtmlPage for other media types"
  end
end
