class IncreasePageSlugLength < ActiveRecord::Migration[8.1]
  def change
    # Increase page_slug from 10 to 16 characters to accommodate 12-char slugs with buffer
    change_column :users, :page_slug, :string, limit: 16
  end
end
