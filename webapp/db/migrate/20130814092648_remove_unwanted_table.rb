class RemoveUnwantedTable < ActiveRecord::Migration
  def up
      drop_table :featured_pages
      drop_table :daily_page_views
      drop_table :people
      drop_table :companies
    end

  def down
  end
end
