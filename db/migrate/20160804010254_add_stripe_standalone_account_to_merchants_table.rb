class AddStripeStandaloneAccountToMerchantsTable < ActiveRecord::Migration
  def change
     add_column :merchants, :standalone, :string
  end
end
