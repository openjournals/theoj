class UniquePaperIndexes < ActiveRecord::Migration

  def up
    remove_index :papers, ["arxiv_id"]
    add_index    :papers, ["arxiv_id"], unique:true

    remove_index :papers, ["sha"]
    add_index    :papers, ["sha"],   unique:true
  end

  def down
    remove_index :papers, ["arxiv_id"]
    add_index    :papers, ["arxiv_id"]

    remove_index :papers, ["sha"]
    add_index    :papers, ["sha"]
  end

end
