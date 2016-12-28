class ReviewerAcceptToString < ActiveRecord::Migration

  def change
    change_column :assignments, :reviewer_accept, :string, limit: 20
  end

end
