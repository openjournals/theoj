class RenameComments < ActiveRecord::Migration
  def change
    rename_table :comments, :annotations
    Annotation.reset_column_information
    
    
    remove_index("annotations", :name => "index_comment_user_id")
    remove_index("annotations", :name => "index_comment_paper_id")
    remove_index("annotations", :name => "index_comment_state")
    remove_index("annotations", :name => "index_comment_parent_id")
    
    add_index "annotations", ["user_id"], :name => "index_annotation_user_id"
    add_index "annotations", ["paper_id"], :name => "index_annotation_paper_id"
    add_index "annotations", ["state"], :name => "index_annotation_state"
    add_index "annotations", ["parent_id"], :name => "index_annotation_parent_id"
  end
end
