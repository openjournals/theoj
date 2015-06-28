# Used for running specs

class Provider
  class TestProvider

    class << self

      def type; :test; end

      def get_attributes(id)
        version = (id.split('-',2).second || 9).to_i
        id      = id.split('-',2).first

        {
            provider_type: self.type,
            provider_id:   id,
            version:       version,
            author_list:   "author list",
            location:      "http://example.com/document/123-9.pdf",
            title:         "title",
            summary:       "summary"
        }
      end

      def full_identifier(paper)
        "#{paper.provider_id}-#{paper.version}"
      end

      def parse_identifier(identifier)
        parts = identifier.split('-', 2)
        parts[1] = parts[1].to_i if parts.length > 1
        parts
      end

    end

  end
end

