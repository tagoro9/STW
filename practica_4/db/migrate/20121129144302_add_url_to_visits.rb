class AddUrlToVisits < ActiveRecord::Migration
  def up
  	add_column :visits, :shortenedUrl_id, :integer
  end

  def down
  	remove_column :visits, :shortenedUrl_id
  end
end
