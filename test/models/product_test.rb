require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  
  def setup
    
    @merchant = Merchant.create(merchantname: "bob", email: "bob@example.com")
    
    @product = @merchant.products.build(name: "chicken parm", summary: "this is the best chicken parm product ever",
              description: "heat oil, add onions, add tomato sauce, add chicken, cook for 20 mins")
  end
  
  test "product should be valid" do
    assert @product.valid?
  end
  
  test "merchant_id should be present" do
    @product.merchant_id = nil
    assert_not @product.valid?
  end
  
  test "name should be present" do
    @product.name = " "
    assert_not @product.valid?
    
  end
  
  test "name length should not be too long" do
    @product.name = "a" * 101
    assert_not @product.valid?
  end
  
  test "name length should not be too short" do
    @product.name = "a" * 4
    assert_not @product.valid?
  end
  
  
  test "summary should be present" do
    @product.summary = " "
    assert_not @product.valid?
    
  end
  
  test "summary length should not be too long" do
    @product.summary = "a" * 151
    assert_not @product.valid?
  end
  
  test "summary length should not be too short" do
     @product.summary = "a" * 9
    assert_not @product.valid?
  end
  
  
  test "description should be present" do
    @product.description = " "
    assert_not @product.valid?
    
  end
  
  test "description length should not be too long" do
    @product.description = "a" * 501
    assert_not @product.valid?
    
  end

  
  test "description length should not be too short" do
    @product.description = "a" * 19
    assert_not @product.valid?
  end
  
  
  
  
  
  
end