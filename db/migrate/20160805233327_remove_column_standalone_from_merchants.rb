class RemoveColumnStandaloneFromMerchants < ActiveRecord::Migration
  def change
    remove_column :merchants, :standalone, :string
  end
end
