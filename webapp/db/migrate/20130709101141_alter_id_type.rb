class AlterIdType < ActiveRecord::Migration
  def up
    execute "Alter Table monthly_trends modify id BIGINT UNSIGNED DEFAULT NULL "
    execute "Alter Table daily_trends modify id BIGINT UNSIGNED DEFAULT NULL "
    execute "Alter Table daily_timelines modify id BIGINT UNSIGNED DEFAULT NULL"
  end

  def down
  end
end
