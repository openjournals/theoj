class AddLocationDataToAnnotation < ActiveRecord::Migration
  def change
    add_column :annotations, :page,      :integer
    add_column :annotations, :xStart,    :float
    add_column :annotations, :yStart,    :float
    add_column :annotations, :xEnd,      :float
    add_column :annotations, :yEnd,      :float
  end
end
