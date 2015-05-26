class CreateFksAndRefactor < ActiveRecord::Migration

  def change
    delete_data
    refactor_columns
    create_foreign_keys
    create_assignees
  end

  def delete_data
    Annotation.delete_all
    Assignment.delete_all
  end

  def refactor_columns

    remove_index  :annotations, name:'index_annotation_user_id'
    rename_column :annotations, :user_id, :assignment_id
    add_index     :annotations, [:assignment_id]

    remove_column :annotations, :category

    remove_index  :assignments, name:'index_assignment_assignee_id'
    remove_column :assignments, :assignee_id

    remove_index  :papers,      name:'index_paper_user_id'
    rename_column :papers,      :user_id, :submittor_id
    add_index     :papers,      [:submittor_id]

    remove_index  :papers,      name:'index_papers_on_fao_id'
    remove_column :papers,      :fao_id

  end

  def create_foreign_keys
    Paper.all.each do |p|
      p.update_attributes!(submittor:User.first) if p.submittor.nil?
    end
    add_foreign_key :papers,      :users,  on_delete: :cascade, column: :submittor_id

    add_foreign_key :assignments, :users,  on_delete: :restrict
    add_foreign_key :assignments, :papers, on_delete: :cascade

    add_foreign_key :annotations, :papers,      on_delete: :cascade
    add_foreign_key :annotations, :assignments, on_delete: :restrict
    add_foreign_key :annotations, :annotations, on_delete: :cascade,   column: 'parent_id'
  end

  def create_assignees
    Paper.all.each do |p|
      p.send(:create_assignments)
    end
  end

end
