class CreateFactoids < ActiveRecord::Migration
  def change
    create_table :factoids do |t|
      t.string :fact
      t.datetime :created_at

      t.timestamps null: false
    end
  end
end
