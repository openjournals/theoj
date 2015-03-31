class UserWithPapersSerializer < UserSerializer
  attributes :papers_as_reviewer,
             :papers_as_collaborator,
             :papers
end
