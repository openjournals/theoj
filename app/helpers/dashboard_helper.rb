module DashboardHelper
  # Are there any review assignments that the reviewer hasn't touched yet?
  # Returns a boolean
  def new_assignments_for(user)
    user.assignments_as_reviewer.any? { |assignment| assignment.annotations.empty? }
  end

  # View logic for deciding what message to show to a user on their dashboard
  # Returns a headline string
  # TODO: Decide what to do here with the editor assignments (for now they're just at the top)
  def headine_for_user(user, reviewing_papers, editor_papers, author_papers)
    string = "Hi #{user.name}."

    if author_papers.any? && reviewing_papers.any?
      string << " You have #{link_to(pluralize(author_papers.size, 'paper'), '#submitted')}
                  submitted papers and #{link_to(pluralize(reviewing_papers.size, 'paper'), '#reviewing')}
                  you're reviewing."
    elsif author_papers.any?
      string << " You have #{link_to(pluralize(author_papers.size, 'paper'), '#submitted')}
                  submitted papers."
    elsif reviewing_papers.any?
      string << " You have #{link_to(pluralize(reviewing_papers.size, 'paper'), '#reviewing')}
                  papers you're reviewing."
    end

    return string.html_safe
  end
end
