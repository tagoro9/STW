class CreateShortenedUrls < ActiveRecord::Migration
  def up
    create_table :Shortened_Urls do |t|
      t.string :url
    end
    add_index :Shortened_Urls, :url
  end

  def down
    drop_table :shortened_urls
  end
end
