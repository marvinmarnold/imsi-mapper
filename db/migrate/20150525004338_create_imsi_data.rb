class CreateImsiData < ActiveRecord::Migration
  def change
    create_table :imsi_data do |t|
      t.integer :aimsicd_thread_level

      t.timestamps null: false
    end
  end
end
