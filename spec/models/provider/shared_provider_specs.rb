require "rails_helper"

shared_examples 'All providers' do

  def provider; described_class; end

  it "should have the required class interface" do
    expect(provider).to respond_to(:type).with(0).arguments
    expect(provider).to respond_to(:get_attributes).with(1).argument
    expect(provider).to respond_to(:full_identifier).with(0).arguments
    expect(provider).to respond_to(:parse_identifier).with(1).argument
  end

  it "should have a symbolic name" do
    expect(provider.type).to be_present
    expect(provider.type).to be_a(Symbol)
  end

  it "should be registered" do
    expect(Provider.get(provider.type)).to eq(provider)
  end

  describe "::get_attributes" do

    shared_examples 'get attributes' do

      it "should return attributes" do
        stub_document
        attributes = provider.get_attributes(id_to_get)
        expect(attributes).to be_a(Hash)
      end

      it "should be able to create a paper" do
        stub_document
        attributes = provider.get_attributes(id_to_get)
        attributes = attributes.merge( submittor: create(:user) )
        expect{ Paper.create(attributes) }.not_to raise_exception
      end

      it "should have the key attributes" do
        stub_document
        expect(provider.get_attributes(id_to_get)).to include(
                                                                   provider_type: an_instance_of(Symbol),
                                                                   provider_id:   an_instance_of(String),
                                                                   version:       an_instance_of(Fixnum)
                                                               )
      end

      it "the provider type should match" do
        stub_document
        attributes = provider.get_attributes(id_to_get)
        expect(attributes[:provider_type]).to be_a(Symbol)
        expect(attributes[:provider_type]).to eq(provider.type)
      end

      it "the id and version should match" do
        stub_document
        attributes = provider.get_attributes(id_to_get)
        expect(attributes[:provider_id]).to eq(document_id_without_version)
        expect(attributes[:version]).to eq(version)
      end

      it "the id and version should round trip" do
        stub_document
        attributes = provider.get_attributes(id_to_get)
        paper = Paper.new(attributes)

        expect(paper.full_provider_id).to eq(document_id)
      end

      it "should have the secondary attributes" do
        stub_document
        expect(provider.get_attributes(id_to_get)).to include(
                                                                   :authors,
                                                                   :document_location,
                                                                   :title,
                                                                   :summary
                                                               )
      end

      it "should return the correct attributes" do
        stub_document
        expect(provider.get_attributes(id_to_get)).to match(expected_attributes)
      end

    end

    describe "using a document id" do

      before do stub_document end
      let(:id_to_get) { document_id }

      it_should_behave_like 'get attributes'

    end

    describe "using a document id without a version" do

      before do stub_document_without_version end
      let(:id_to_get) { document_id_without_version }

      it_should_behave_like 'get attributes'

    end

    it "should raise a DocumentNotFound exception if the document is not found" do
      stub_document_not_found
      expect{ provider.get_attributes(document_id) }.to raise_exception(Provider::Error::DocumentNotFound)
    end

  end

  describe "::full_identifier" do

    it "should create a matching full id" do
      paper = Paper.new(
          provider_type: provider.type,
          provider_id:   document_id_without_version,
          version:       version
      )

      expect(provider.full_identifier(provider_id:document_id_without_version, version:version)).to eq(document_id)
    end

    it "should create a matching full id without a version" do
      paper = Paper.new(
          provider_type: provider.type,
          provider_id:   document_id_without_version,
          version:       version
      )

      expect(provider.full_identifier(provider_id:document_id_without_version)).to eq(document_id_without_version)
    end

  end

  describe "::parse_identifier" do

    it "should split the identifier into 2 correct parts" do
      result = provider.parse_identifier(document_id)
      expect(result).to eq({provider_id:document_id_without_version, version:version})
    end

    it "should split an identifier without version info into 1 correct part" do
      result = provider.parse_identifier(document_id_without_version)
      expect(result.length).to eq(1)
      expect(result).to eq({provider_id:document_id_without_version})
    end

    it "should fail for an invalid identifier" do
      expect {
         provider.parse_identifier('~!@#$%^&*()')
      }.to raise_exception(Provider::Error::InvalidIdentifier)
    end

  end

end
