class RenameColumnChefIdToMerchantIdInTableProducts < ActiveRecord::Migration
  def change
    rename_column :products, :chef_id, :merchant_id
  end
end
