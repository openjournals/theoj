class AddArxivIdIndex < ActiveRecord::Migration

  def change
    remove_index :papers, name: "index_papers_on_arxiv_id"
    add_index    :papers, [:arxiv_id, :version], unique: true
  end

end
