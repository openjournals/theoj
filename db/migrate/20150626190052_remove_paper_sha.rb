class RemovePaperSha < ActiveRecord::Migration

  def change
    remove_index  :papers, name: "index_papers_on_sha"
    remove_column :papers, :sha
  end

end
