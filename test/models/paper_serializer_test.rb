require 'test_helper'

class PaperSerializerTest < ActiveSupport::TestCase
  test "serialize!" do
    user = User.create!
    serializer = PaperSerializer.new(Paper.create!(:location => "http://example.com", :title => "Teh awesomeness", :user => user))

    hash = has_from_json(serializer.to_json)
    ["user_permissions", "location", "state", "submitted_at", "title", "version", "created_at", "pending_issues_count", "sha"].each do |key|
      assert hash["paper"].has_key?(key), "Missing key #{key}"
    end
  end
end
