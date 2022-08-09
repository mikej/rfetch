# frozen_string_literal: true

module RFetch
  # Allows a non HTML page to be treated as a Page
  class NonHtmlPage
    def title
      nil
    end

    def description
      nil
    end

    def meta_content(name, name_attribute: "name")
      nil
    end
  end
end
