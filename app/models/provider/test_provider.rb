# Used for running specs

class Provider
  class TestProvider < BaseProvider

    self.type = :test
    self.version_separator = '-'

    class << self

      def get_attributes(id)
        parsed = parse_identifier(id)

        {
            provider_type:     self.type,
            provider_id:       parsed[:provider_id],
            version:           parsed[:version] || 9,
            authors:           "author list",
            document_location: "http://example.com/document/123-9.pdf",
            title:             "title",
            summary:           "summary"
        }
      end

      private

      def identifier_valid?(identifier)
        /^[\w.-]+$/ === identifier
      end

    end

  end
end

