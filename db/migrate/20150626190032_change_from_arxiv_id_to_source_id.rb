class ChangeFromArxivIdToSourceId < ActiveRecord::Migration

  def change
    remove_index   :papers, name: "index_papers_on_arxiv_id_and_version"
    rename_column :papers, :arxiv_id, :provider_id

    add_column    :papers, :provider_type, :string, limit:10

    reversible do |dir|
      dir.up do
        execute('DELETE FROM  papers WHERE provider_id IS NULL')
        execute('UPDATE papers SET provider_type="arxiv"')
      end
    end

    change_column_null :papers, :provider_type, false
    change_column_null :papers, :provider_id,   false

    add_index :papers, [:provider_type, :provider_id, :version], unique: true

  end

end
