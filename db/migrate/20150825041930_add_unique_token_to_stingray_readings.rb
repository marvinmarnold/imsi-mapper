class AddUniqueTokenToStingrayReadings < ActiveRecord::Migration
  def change
        add_column :stingray_readings, :unique_token, :string
  end
end
