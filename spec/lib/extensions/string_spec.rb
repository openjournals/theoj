require "rails_helper"

describe String do

  describe "#a_or_an" do

    it "should return a result" do
      expect( 'elephant'.a_or_an ).to eq('an')
      expect( 'cat'.a_or_an ).to eq('a')
    end

    it "should be case insensitive" do
      expect( 'Elephant'.a_or_an ).to eq('an')
      expect( 'Cat'.a_or_an ).to eq('a')
    end

    it "should return '' for empty strings" do
      expect( ''.a_or_an).to eq('')
    end

    it "should handle non-alpha characters" do
      expect( '0'.a_or_an).to eq('a')
      expect( '~'.a_or_an).to eq('a')
    end

  end

end
