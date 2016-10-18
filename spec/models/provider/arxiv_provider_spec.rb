require_relative 'shared_provider_specs'
require "rails_helper"

describe Provider::ArxivProvider do

  def stub_document
    stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653v2").to_return(fixture('arxiv/1311.1653v2.xml'))
  end

  def stub_document_without_version
    stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653").to_return(fixture('arxiv/1311.1653v2.xml'))
  end

  def stub_document_not_found
    stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653v2").to_return(fixture('arxiv/not_found.xml'))
  end

  def document_id
    '1311.1653v2'
  end

  def document_id_without_version
    '1311.1653'
  end

  def version
    2
  end

  def expected_attributes
    {
        provider_type:     :arxiv,
        provider_id:       "1311.1653",
        version:           2,
        authors:           "Mar Álvarez-Álvarez, Angeles I. Díaz",
        document_location: "https://arxiv.org/pdf/1311.1653v2.pdf",
        title:             "A photometric comprehensive study of circumnuclear star forming rings: the sample",
        summary:           a_string_matching(/^We present photometry.*in a second paper.$/)
    }
  end

  it_should_behave_like 'All providers'

  it "should include the original message when a document is not found" do
    stub_document_not_found
    expect{ described_class.get_attributes(document_id) }.to raise_exception(Provider::Error::DocumentNotFound).with_message("Manuscript 1311.1653v2 doesn't exist on arXiv")
  end

end
