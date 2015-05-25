require "rails_helper"

describe AnnotationSerializer do

  it "should initialize properly" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include('id', 'paper_id', 'state', 'parent_id',
                            'body', 'assignment', 'created_at',
                            'page', 'xStart', 'xEnd', 'yStart', 'yEnd')
  end

  it "should serialize the assignment as a sha" do
    annotation = create(:annotation)
    serializer = AnnotationSerializer.new(annotation)
    hash = hash_from_json(serializer.to_json)

    expect(hash['assignment']).to eq(annotation.assignment.sha)
  end

end
