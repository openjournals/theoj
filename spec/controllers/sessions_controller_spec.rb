require "rails_helper"

describe SessionsController do
  describe "#orcid_name_for" do
    it "queries the ORCID API for the username based upon the ORCID ID" do
      # Check spec_helper.rb to see how this is being stubbed
      user = create(:user, :uid => '0000-0001-7857-2795')
      
      expect(controller.send(:orcid_name_for, user.uid)).to eq("Albert Einstein")
    end
  end
end
