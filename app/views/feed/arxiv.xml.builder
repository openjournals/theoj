xml.instruct!
xml.preprint   'xmlns':              'http://arxiv.org/doi_feed',
               'xmlns:xsi':          'http://www.w3.org/2001/XMLSchema-instance',
               'identifier':         'The Open Journal of Astrophysics arXiv.org DOI feed',
               'version':            'DOI SnappyFeed v1.0',
               'xsi:schemaLocation': 'http://arxiv.org/doi_feed http://arxiv.org/schemas/doi_feed.xsd' do

  xml.date(year: date.year, month: date.month, day: date.day)

  papers.each do |paper|
    xml.article paper
  end

end