require "rails_helper"

describe AssignmentSerializer do

  it "should initialize properly" do
    assignment = create(:assignment)
    serializer = AssignmentSerializer.new(assignment)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include('role', 'sha')
  end

  it "should include user info based on the role when no user is logged in" do

    user       = create(:user, name:'John Doe')
    assignment = create(:assignment, user:user)
    serializer = AssignmentSerializer.new(assignment)

    assignment.update_attributes(role:'submittor')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'collaborator')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'editor')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'reviewer')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to be_nil

  end

  it "should include user info based on the role when a normal user is logged in" do
    current_user = create(:user)

    user       = create(:user, name:'John Doe')
    assignment = create(:assignment, user:user)
    serializer = AssignmentSerializer.new(assignment, scope:current_user)

    assignment.update_attributes(role:'submittor')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'collaborator')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'editor')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

    assignment.update_attributes(role:'reviewer')
    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to be_nil

  end

  it "should include reviewer info when the editor is logged in" do
    current_user = set_editor

    user       = create(:user, name:'John Doe')
    assignment = create(:assignment, :reviewer, user:user)
    serializer = AssignmentSerializer.new(assignment, scope:current_user)

    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')

  end

  it "should include reviewer info when the reviewer is logged in" do
    user       = create(:user, name:'John Doe')
    assignment = create(:assignment, :reviewer, user:user)
    serializer = AssignmentSerializer.new(assignment, scope:user)

    hash = hash_from_json(serializer.to_json)
    expect(hash['user']).to include('name' => 'John Doe')
  end

end
