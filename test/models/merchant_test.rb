require 'test_helper'

class MerchantTest < ActiveSupport::TestCase
  
  def setup
    @merchant = Merchant.new(merchantname: "john", email: "john@example.com")
  end
  
  test "merchant should be valid" do
    assert @merchant.valid?
  end
  
  test "merchant should be present" do
    @merchant.merchantname = " "
    assert_not @merchant.valid?
    
  end
  
  test "merchant length should not greater than 400" do
    @merchant.merchantname = "a" * 401
    assert_not @merchant.valid?
  end
  
  test "merchantname length should not be less than 3" do
    @merchant.merchantname = "a" * 2
    assert_not @merchant.valid?
  end
  
  test "email should be present" do
    @merchant.email = " "
    assert_not @merchant.valid?
  end
  
  test "email lenght should be within bounds" do
    @merchant.email = "a" * 101 + "@example.com"
    assert_not @merchant.valid?
  end
  
  test "email address should be unique" do
    
    dup_merchant = @merchant.dup
    dup_merchant.email = @merchant.email.upcase
    @merchant.save
    assert_not dup_merchant.valid?

  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@eee.com R_TDD-DS@eee.hello.org user@example.com first.last@eee.au laura+joe@monk.cm]
    valid_addresses.each do |va|
      @merchant.email = va
      assert @merchant.valid? ,'#{va.inspect} should be valid'
    end
  end
  
   test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_eee.org user.name@example. eee@i_am_.com]
    invalid_addresses.each do |ia|
      @merchant.email = ia
      assert_not @merchant.valid? , '#{ia.inspect} should be invalid'
    end
    
  end
  
end