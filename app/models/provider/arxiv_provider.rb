class Provider
  class ArxivProvider < BaseProvider

    self.type = :arxiv
    self.version_separator = 'v'

    class << self

      def get_attributes(id)

        manuscript = Arxiv.get(id.to_s)
        attributes_from_manuscript(manuscript)

      rescue Arxiv::Error::ManuscriptNotFound => ex
        raise Error::DocumentNotFound.new(ex.message)
      end

      private

      def attributes_from_manuscript(manuscript)
        {
            provider_type:     self.type,
            provider_id:       manuscript.arxiv_id,
            version:           manuscript.version,

            title:             manuscript.title,
            summary:           manuscript.summary,
            document_location: manuscript.pdf_url.sub('http://', 'https://'),
            authors:           manuscript.authors.collect{|a| a.name}.join(", ")
        }
      end

      private

      def identifier_valid?(identifier)
        Arxiv::ID_FORMAT === identifier
      end

    end

  end
end

