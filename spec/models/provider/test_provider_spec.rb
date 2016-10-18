require_relative 'shared_provider_specs'
require "rails_helper"

describe Provider::TestProvider do

  def stub_document; end

  def stub_document_without_version; end

  def stub_document_not_found
    allow(described_class).to receive(:get_attributes).and_raise(Provider::Error::DocumentNotFound)
  end

  def document_id
    '123-9'
  end

  def document_id_without_version
    '123'
  end

  def version
    9
  end

  def expected_attributes
    {
        provider_type:     :test,
        provider_id:       "123",
        version:           9,
        authors:           "author list",
        document_location: "https://example.com/document/123-9.pdf",
        title:             "title",
        summary:           "summary"
    }
  end

  it_should_behave_like 'All providers'

end
