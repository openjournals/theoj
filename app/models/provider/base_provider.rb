class Provider
  class BaseProvider

    class_attribute :type
    class_attribute :version_separator

    class << self

      def full_identifier(**params)
        result = params[:provider_id].dup
        result << "#{version_separator}#{params[:version]}" if params[:version]
        result
      end

      def parse_identifier(identifier)
        parts = identifier.split(version_separator, 2)
        {
            provider_id: parts[0],
            version:     parts[1] && parts[1].to_i
        }.compact
      end

    end

  end
end

