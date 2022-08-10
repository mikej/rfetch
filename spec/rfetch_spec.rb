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
    pending "follows redirects and returns the target URL in the result"
    pending "follows multiple redirects and returns the last URL in the result"
    pending "detects redirect loops"
    pending "handles redirects to a path only (without a host in Location)"
  end
end
