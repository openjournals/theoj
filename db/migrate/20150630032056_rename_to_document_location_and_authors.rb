class RenameToDocumentLocationAndAuthors < ActiveRecord::Migration
  def change

    rename_column :papers, :location,    :document_location
    rename_column :papers, :author_list, :authors

  end
end
