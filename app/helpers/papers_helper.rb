module PapersHelper
  def status_badge_for(paper)
    return image_tag('badges/unknown.svg') unless paper
    
    case paper.state
    when "pending"
      image_tag('badges/unknown.svg')
    when "submitted"
      image_tag('badges/submitted.svg')
    when "under_review"
      image_tag('badges/review.svg')
    when "accepted"
      image_tag('badges/accepted.svg')
    when "rejected"
      image_tag('badges/rejected.svg')
    end
  end
end
