class DropUselessTables < ActiveRecord::Migration
  def up
    drop_table :new_pages
    drop_table :new_daily_trends
    drop_table :new_daily_timelines
    drop_table :weekly_trends
  end

  def down
  end
end
