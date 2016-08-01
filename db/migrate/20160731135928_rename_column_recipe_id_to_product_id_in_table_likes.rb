class RenameColumnRecipeIdToProductIdInTableLikes < ActiveRecord::Migration
  def change
    rename_column :likes, :recipe_id, :product_id
  end
end
