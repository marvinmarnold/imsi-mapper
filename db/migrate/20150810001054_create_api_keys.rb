class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :access_token
      t.string :name
      t.string :comment

      t.timestamps null: false
    end
  end
end
