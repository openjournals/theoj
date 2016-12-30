module PapersHelper

  def state_badge_for(paper)
    return image_tag('badges/unknown.svg') unless paper
    
    case paper.state
      when "submitted"
        image_tag('badges/submitted.svg')
      when "under_review"
        image_tag('badges/review.svg')
      when "review_completed"
        image_tag('badges/completed.svg')
      when "rejected"
        image_tag('badges/rejected.svg')
      when "accepted"
        image_tag('badges/accepted.svg')
      when "published"
        image_tag('badges/published.svg')
      else
        image_tag('badges/unknown.svg')
    end
  end
end
