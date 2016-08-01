class RenameColumnChefIdToMerchantIdInTableLikes < ActiveRecord::Migration
  def change
    rename_column :likes, :chef_id, :merchant_id
  end
end
