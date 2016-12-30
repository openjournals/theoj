FactoryGirl.define do
  factory :user do
    provider  'orcid'
    name  'John Doe'
    created_at  { Time.now }
    admin false
    editor false

    factory :admin do
      name  'John Admin'
      admin true
    end

    factory :editor do
      name   'John the Editor'
      editor true
    end

  end
end
