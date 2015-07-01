# Lookup class for Providers

class Provider

  SEPARATOR = ':'

  class << self

    def parse_identifier(identifier)
      raise Error::InvalidIdentifier.new unless identifier.present?
      provider_type, identifier = identifier.split(SEPARATOR, 2)
      raise Error::InvalidIdentifier.new unless identifier.present?

      provider = self[provider_type]
      parsed   = provider.parse_identifier(identifier)
      parsed.merge(
          provider_type:   provider_type
      )
    end

    def get_attributes(identifier)
      raise Error::InvalidIdentifier.new unless identifier.present?
      provider_type,identifier = identifier.split(SEPARATOR, 2)
      raise Error::InvalidIdentifier.new unless identifier.present?

      provider = self[provider_type]
      provider.get_attributes(identifier)
    end

    def [](type)
      get(type) || raise( Error::ProviderNotFound.new("Provider not found for '#{type}'") )
    end

    def get(type)
      providers[ type && type.downcase.to_sym ]
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
        klass_name = File.basename(file,'.rb').camelize
        next if klass_name == 'BaseProvider'
        klass  = "Provider::#{klass_name}".constantize
        add( klass)
      end

    end

  end

  module Error
    class ProviderNotFound  < StandardError; end
    class DocumentNotFound  < StandardError; end
    class InvalidIdentifier < StandardError; end
  end

end