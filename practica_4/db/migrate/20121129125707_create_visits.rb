class CreateVisits < ActiveRecord::Migration
  def up
  	create_table :visits do |t|
  		t.string :country
  		t.datetime :at
  	end
  	add_index :visits, :country
  end

  def down
  	drop_table :visits
  end
end
