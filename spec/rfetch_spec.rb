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
  end
end
