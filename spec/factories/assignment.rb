FactoryGirl.define do
  factory :assignment do
    user
    paper
    created_at     { Time.now }
    updated_at     { Time.now }

    factory :assignment_as_reviewer do
      role "reviewer"
    end

    factory :assignment_as_editor do
      role "editor"
    end

    factory :assignment_as_collaborator do
      role "collaborator"
    end
  end
end
