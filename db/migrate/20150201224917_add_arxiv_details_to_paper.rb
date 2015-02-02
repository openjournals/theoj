class AddArxivDetailsToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :arxiv_id,     :string
    add_column :papers, :summary,      :text
    add_column :papers, :author_list,  :text

    add_index :papers, ["arxiv_id"]

  end
end
