require "rails_helper"

describe AnnotationSerializer do

  it "should initialize properly" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include('id', 'paper_id', 'state', 'parent_id',
                            'body', 'author', 'created_at',
                            'page', 'xStart', 'xEnd', 'yStart', 'yEnd')
  end

  it "should serialize the reviewers as anonymous when no user is logged in" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation)
    hash = hash_from_json(serializer.to_json)

    expect(hash['author']).to include('tag_name', 'sha')
    expect(hash['author']).not_to include('name', 'email', 'created_at', 'picture')
  end

  it "should serialize the reviewers as anonymous when a user is logged in" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation, scope: create(:user) )
    hash = hash_from_json(serializer.to_json)

    expect(hash['author']).to include('tag_name', 'sha')
    expect(hash['author']).not_to include('name', 'email', 'created_at', 'picture')
  end

  it "should serialize the reviewers as public when an editor is logged in" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation, scope: create(:editor) )
    hash = hash_from_json(serializer.to_json)

    expect(hash['author']).to include('tag_name', 'sha', 'name', 'email', 'created_at', 'picture')
  end

end
