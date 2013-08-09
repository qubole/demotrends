class CreateMonthlyTrends < ActiveRecord::Migration
  def up
    create_table :monthly_trends do |t|
      t.datetime  :date
      t.references :page
      t.float :trend
      t.integer :total_pageviews
      t.timestamps
      end
    add_index :monthly_trends,  :date
  end

  def down
    drop_table :monthly_trends
  end
end
