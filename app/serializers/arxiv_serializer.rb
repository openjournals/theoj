# Serialize a Paper in the Arxiv format

class ArxivSerializer < ActiveModel::Serializer

  attributes :arxiv_url, :title, :summary, :links, :authors

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

end
