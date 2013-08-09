class AddDateToDailyTrends < ActiveRecord::Migration
  def up
    add_column :daily_trends, :date, :datetime
    add_index :daily_trends,  :date
  end
  
  def down
    remove_column :daily_trends, :date
  end
end
