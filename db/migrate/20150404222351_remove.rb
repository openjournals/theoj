class Remove < ActiveRecord::Migration

  def up
    execute <<-SQL
      UPDATE Papers
         SET state='submitted'
       WHERE state='pending'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE Papers
         SET state='pending'
       WHERE state='submitted'
    SQL
  end

end
