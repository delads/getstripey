class RenameTableRecipesToProducts < ActiveRecord::Migration
  def change
    rename_table :recipes, :products
  end
end
