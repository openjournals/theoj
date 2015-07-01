# Serialize a Paper in the format for previewing documents

class PreviewPaperSerializer < BaseSerializer

  attributes :typed_provider_id,
             :title,
             :summary,
             :document_location,
             :authors,
             :is_existing, #@mro #@todo - rename in Polymer
             :is_self_owned #@mro #@todo - rename in Polymer

  def is_self_owned
    current_user && current_user == object.submittor
  end

  def is_existing
    object.persisted?
  end

end
