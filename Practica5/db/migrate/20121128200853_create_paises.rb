class CreatePaises < ActiveRecord::Migration
  def up
    create_table :paises do |t|
      t.string :url
      t.string :pais
      t.integer :visitas, :default => 0
    end
    add_index :paises, :url
  end

  def down
    drop_table :paises
  end
end
