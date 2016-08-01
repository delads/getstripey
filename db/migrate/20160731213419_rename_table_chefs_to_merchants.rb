class RenameTableChefsToMerchants < ActiveRecord::Migration
  def change
    rename_table :chefs, :merchants
  end
end
