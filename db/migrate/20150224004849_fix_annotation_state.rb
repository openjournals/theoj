class FixAnnotationState < ActiveRecord::Migration

  def up
    Annotation.all.where(state:'new').update_all(state:'unresolved')
  end

  def down
    Annotation.all.where(state:'unresolved').update_all(state:'new')
  end

end
