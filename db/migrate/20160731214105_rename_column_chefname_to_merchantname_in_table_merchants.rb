class RenameColumnChefnameToMerchantnameInTableMerchants < ActiveRecord::Migration
  def change
    rename_column :merchants, :chefname, :merchantname
  end
end
