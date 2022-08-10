# frozen_string_literal: true

RSpec.describe RFetch::Helpers do
  describe "ensure_protocol" do
    pending "prepends https when it is supported"
    pending "prepends http when it is supported, but https isn't"
    pending "does not prepend a protocol if one is already present"
    pending "raises an exception if the URL is invalid"
    pending "raises an exception if no working protocol can be determined"
  end
end
