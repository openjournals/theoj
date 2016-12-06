class FeedController < ApplicationController

  # arXiv metadata https://arxiv.org/help/bib_feed
  def arxiv
    papers     = Paper.published
                      .where(provider_type: Provider::ArxivProvider.type)
                      .where('updated_at >= ?', 3.months.ago)

    attributes = papers.map { |paper| arxiv_attributes(paper) }

    render 'arxiv', locals: {papers: attributes, date: Time.now}
  end

  private

  def arxiv_attributes(paper)
    {
        preprint_id: "arXiv:#{paper.provider_id}",
        doi:         paper.doi,
        journal_ref: "The Open Journal of Astrophysics, #{paper.created_at.year}"
    }
  end

end
