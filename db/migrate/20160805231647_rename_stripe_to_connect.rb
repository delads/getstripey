class RenameStripeToConnect < ActiveRecord::Migration
  def change
    rename_table :stripes, :connects
  end
end
