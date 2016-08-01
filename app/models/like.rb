class Like < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :product
  
  validates_uniqueness_of :merchant, scope: :product
end
