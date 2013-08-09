class AddDateToDailyTimeLine < ActiveRecord::Migration
  def up
    add_column :daily_timelines, :on_date, :datetime
    add_index :daily_timelines,  :on_date
  end
  
  def down
    remove_column :daily_timelines, :on_date
  end
end
