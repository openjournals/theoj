module PapersHelper

  def state_badge_for(paper)
    return image_tag('badges/unknown.svg') unless paper
    
    case paper.state
      when "submitted"
        image_tag('badges/submitted.svg')
      when "under_review"
        image_tag('badges/review.svg')
      when "accepted"
        image_tag('badges/accepted.svg')
      when "rejected"
        image_tag('badges/rejected.svg')
      else
        image_tag('badges/unknown.svg')
    end
  end
end
