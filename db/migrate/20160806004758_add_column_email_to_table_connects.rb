class AddColumnEmailToTableConnects < ActiveRecord::Migration
  def change
    add_column :connects, :email, :string
  end
end
