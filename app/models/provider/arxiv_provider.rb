class Provider
  class ArxivProvider

    class << self

      def type; :arxiv; end

      def get_attributes(id)

        manuscript = Arxiv.get(id.to_s)
        attributes_from_manuscript(manuscript)

      rescue Arxiv::Error::ManuscriptNotFound => ex
        raise Error::DocumentNotFound.new(ex.message)
      end

      def full_identifier(paper)
        "#{paper.provider_id}v#{paper.version}"
      end

      def parse_identifier(identifier)
        parts = identifier.split('v', 2)
        parts[1] = parts[1].to_i if parts.length > 1
        parts
      end

      private

      def attributes_from_manuscript(manuscript)
        {
            provider_type: self.type,
            provider_id:   manuscript.arxiv_id,
            version:       manuscript.version,

            title:         manuscript.title,
            summary:       manuscript.summary,
            location:      manuscript.pdf_url,
            author_list:   manuscript.authors.collect{|a| a.name}.join(", ")
        }
      end

    end

  end
end

