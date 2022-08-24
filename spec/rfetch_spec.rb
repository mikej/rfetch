# frozen_string_literal: true

RSpec.describe RFetch do
  it "has a version number" do
    expect(RFetch::VERSION).not_to be nil
  end

  describe "get" do
    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
    before(:each) do
      RFetch.connection = Faraday.new { |b| b.adapter(:test, stubs) }
    end

    it "fetches a page" do
      stubs.get("https://example.com") do
        [
          200,
          { "Content-Type": "text/plain" },
          "This is an example"
        ]
      end

      result = RFetch.get("https://example.com")

      expect(result).to eq(RFetch::Result.new("https://example.com", 200, "text/plain", "This is an example"))
    end

    pending "raises an exception if the specified URL is not found"

    it "follows a permanent redirect and returns the target URL in the result" do
      stubs.get("https://old.com") do
        [
          301,
          { "Location": "https://new.com" }
        ]
      end

      stubs.get("https://new.com") do
        [
          200,
          { "Content-Type": "text/plain" },
          "Contents of the new page"
        ]
      end

      result = RFetch.get("https://old.com")

      expect(result).to eq(RFetch::Result.new("https://new.com", 200, "text/plain", "Contents of the new page"))
    end

    it "follows multiple permanent redirects and returns the last URL in the result" do
      stubs.get("https://old.com") do
        [
          301,
          { "Location": "https://middle.com" }
        ]
      end

      stubs.get("https://middle.com") do
        [
          301,
          { "Location": "https://new.com" }
        ]
      end

      stubs.get("https://new.com") do
        [
          200,
          { "Content-Type": "text/plain" },
          "Contents of the new page"
        ]
      end

      result = RFetch.get("https://old.com")

      expect(result).to eq(RFetch::Result.new("https://new.com", 200, "text/plain", "Contents of the new page"))
    end

    it "follows a permanent redirect followed by a temporary redirect, returning the URL from the permanent redirect" do
      stubs.get("https://old.com") do
        [
          301,
          { "Location": "https://permanent.com" }
        ]
      end

      stubs.get("https://permanent.com") do
        [
          302,
          { "Location": "https://temporary.com" }
        ]
      end

      stubs.get("https://temporary.com") do
        [
          200,
          { "Content-Type": "text/plain" },
          "This is a temporary page"
        ]
      end

      result = RFetch.get("https://old.com")

      expect(result).to eq(RFetch::Result.new("https://permanent.com", 200, "text/plain", "This is a temporary page"))
    end

    it "returns the URL of the last permanent redirect that came before any temporary redirects" do
      stubs.get("https://old.com") do
        [301, { "Location": "https://permanent.com" }]
      end

      stubs.get("https://permanent.com") do
        [302, { "Location": "https://temporary.com" }]
      end

      stubs.get("https://temporary.com") do
        [301, { "Location": "https://permanent-redirect-for-temporary.com" }]
      end

      stubs.get("https://permanent-redirect-for-temporary.com") do
        [
          200,
          { "Content-Type": "text/plain" },
          "Resulting page"
        ]
      end

      result = RFetch.get("https://old.com")

      expect(result).to eq(RFetch::Result.new("https://permanent.com", 200, "text/plain", "Resulting page"))
    end

    pending "detects redirect loops"
    pending "handles redirects to a path only (without a host in Location)"
  end
end
