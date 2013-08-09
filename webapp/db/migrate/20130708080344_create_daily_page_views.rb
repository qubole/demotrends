class CreateDailyPageViews < ActiveRecord::Migration
  def self.up
     create_table :daily_page_views do |t|
       t.datetime :date
       t.references :page
       t.integer :pageviews
       t.timestamps
     end
     add_index :daily_page_views,  :page_id
  end
  
  def down
    drop_table :daily_page_views
  end
end
