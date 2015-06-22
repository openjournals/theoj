require "rails_helper"

describe AuthenticatedUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = AuthenticatedUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("name", "email",
                                         "created_at", "picture", "sha",
                                         "has_papers_as_submittor", "has_papers_as_reviewer", "has_papers_as_editor",
                                         "editor", "admin")
  end

end
