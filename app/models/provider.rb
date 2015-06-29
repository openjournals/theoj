# Lookup class for Providers

class Provider

  SEPARATOR = ':'

  class << self

    def parse_identifier(identifier)
      raise Error::InvalidIdentifier.new unless identifier.present?
      provider_type, provider_id = identifier.split(':', 2)
      raise Error::InvalidIdentifier.new unless provider_id.present?

      provider = self[provider_type]
      provider_id, version = provider.parse_identifier(provider_id)

      if version
        [provider_type, provider_id, version.to_i]
      else
        [provider_type, provider_id]
      end
    end

    def [](type)
      get(type) || raise( Error::ProviderNotFound.new("Provider not found for '#{type}'") )
    end

    def get(type)
      providers[ type.downcase.to_sym ]
    end

    def providers
      load_providers unless providers_loaded?
      @providers
    end

    private

    def providers_loaded?
      @providers
    end

    def add(provider)
      raise "Provider #{provider} doesn't respond to type" if ! provider.respond_to?(:type)
      @providers[ provider.type.downcase.to_sym ] = provider
    end

    def load_providers
      @providers = {}

      path = File.join( File.dirname(__FILE__), 'provider', '*_provider.rb')
      Dir[path].each do |file|
        klass_name  = 'Provider::' + File.basename(file,'.rb').camelize
        add( klass_name.constantize )
      end

    end

  end

  module Error
    class ProviderNotFound  < StandardError; end
    class DocumentNotFound  < StandardError; end
    class InvalidIdentifier < StandardError; end
  end

end