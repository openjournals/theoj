# Serialize a Paper in the Arxiv format

class ArxivSerializer < BaseSerializer

  attributes :arxiv_url,
             :arxiv_id,
             :version,
             :sha,
             :title,
             :summary,
             :links,
             :authors,
             :source,
             :self_owned

  def arxiv_url
    object.location.sub(/\.pdf$/,'')
  end

  def links
    [
        {
            url:          object.location,
            content_type: 'application/pdf'
        }
    ]
  end

  def authors
    object.author_list
  end

  def self_owned
    current_user && current_user == object.submittor
  end

  def source
    'theoj'
  end

end
