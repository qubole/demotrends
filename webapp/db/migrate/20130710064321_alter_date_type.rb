class AlterDateType < ActiveRecord::Migration
  def up
    execute "Alter Table monthly_trends modify date Date"
    execute "Alter Table daily_trends modify date Date"
    execute "Alter Table daily_timelines modify on_date Date"
  end

  def down
  end
end
