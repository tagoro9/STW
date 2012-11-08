class AddIndexToShortenedUrls < ActiveRecord::Migration
  def up
  	add_index :shortened_urls, :custom
  end

  def down
  	remove_index :shortened_urls, :custom
  end
end
