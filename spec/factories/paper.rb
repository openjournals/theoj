FactoryGirl.define do
  factory :paper do
    document_location "https://example.com/1234"
    state              "submitted"
    title              "My awesome paper"
    summary            "Summary of my awesome paper"
    authors            "John Smith, Paul Adams, Ella Fitzgerald"
    association        :submittor, factory: :user
    provider_type      'test'
    provider_id        { SecureRandom.hex }
    version            1
    created_at         { Time.now }
    updated_at         { Time.now }

    Paper.aasm.states.each do |s|
      trait s.name do state s.name end
    end

    ignore do
      reviewer     nil
      collaborator nil
      arxiv_id     nil
    end

    after(:build) do |paper, factory|

      if factory.arxiv_id
        parsed = Provider::ArxivProvider.parse_identifier(factory.arxiv_id)
        paper.provider_type  = 'arxiv'
        paper.provider_id    = parsed[:provider_id]
        paper.version        = parsed[:version] if parsed[:version].present?
      end

      paper.send(:create_assignments) if paper.submittor

      if factory.collaborator
        collaborators = Array(factory.collaborator==true ? create(:user) : factory.collaborator)
        collaborators.each do |c|
          paper.assignments.build(role: :collaborator, user:c)
        end
      end

      if factory.reviewer
        reviewers = Array(factory.reviewer==true ? create(:user) : factory.reviewer)
        reviewers.each do |r|
          paper.assignments.build(role: :reviewer, user:r)
        end
      end

    end

  end
end
