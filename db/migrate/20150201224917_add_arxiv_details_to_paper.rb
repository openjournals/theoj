class AddArxivDetailsToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :arxiv_id,     :string
    add_column :papers, :summary,      :string
    add_column :papers, :author_list,  :string

    add_index :papers, ["arxiv_id"]

  end
end
