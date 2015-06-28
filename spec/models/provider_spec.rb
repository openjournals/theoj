require "rails_helper"

describe Provider  do

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
