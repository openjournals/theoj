require "rails_helper"

describe Provider  do

  describe "[]" do

    it "should return a provider" do
      expect( Provider[:arxiv] ).to be(Provider::ArxivProvider)
    end

    it "should not be case sensitive" do
      expect( Provider[:Arxiv] ).to be(Provider::ArxivProvider)
    end

    it "should accept a string" do
      expect( Provider['arxiv'] ).to be(Provider::ArxivProvider)
    end

    it "should fail if no provider is found" do
      expect{ Provider['not_found'] }.to raise_exception(Provider::Error::ProviderNotFound)
    end

  end

  describe "::parse_identifier" do

    it "should split the identifier into 3 correct parts" do
      result = Provider.parse_identifier('test:1234-9')
      expect(result.length).to eq(3)
      expect(result).to eq(['test', '1234', 9])
    end

    it "should split an identifier without version info into 2 correct parts" do
      result = Provider.parse_identifier('test:1234')
      expect(result.length).to eq(2)
      expect(result).to eq(['test', '1234'])
    end

    it "should raise an exception if the identifier is blank" do
      expect{ Provider.parse_identifier(nil) }.to raise_exception(Provider::Error::InvalidIdentifier)
      expect{ Provider.parse_identifier('' ) }.to raise_exception(Provider::Error::InvalidIdentifier)
      expect{ Provider.parse_identifier(' ') }.to raise_exception(Provider::Error::InvalidIdentifier)
    end

    it "should raise an exception if the provider is given but the identifier is blank" do
      expect{ Provider.parse_identifier('test:') }.to raise_exception(Provider::Error::InvalidIdentifier)
      expect{ Provider.parse_identifier('test' ) }.to raise_exception(Provider::Error::InvalidIdentifier)
    end

    it "should raise an exception if the provider is not known" do
      expect{ Provider.parse_identifier('unknown:1234') }.to raise_exception(Provider::Error::ProviderNotFound)
    end

  end

end
