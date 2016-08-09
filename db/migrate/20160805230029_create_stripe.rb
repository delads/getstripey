class CreateStripe < ActiveRecord::Migration
  def change
    create_table :stripes do |t|
       t.string :stripe_publishable_key
       t.string :stripe_user_id
       t.string :access_token
       t.integer :merchant_id
    end
  end
end
