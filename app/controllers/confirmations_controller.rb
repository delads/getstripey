class ConfirmationsController < ApplicationController
  before_action :require_same_user, only: [:edit, :update]
  before_action :set_product
  before_action :set_merchant
  before_action :set_env
  
  def new
    @source = params[:source]
    @client_secret = params[:client_secret]
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    @stripe_user_publishable_api_key = @connect.stripe_publishable_key
    
  end
  
  def charge_ideal
  
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
   
   Stripe.api_key = @stripe_secret_api_key
   
    source = Stripe::Source.retrieve(params[:source],{:stripe_account => @connect.stripe_user_id})
    @product = Product.find(source.metadata.product_id)
    
    charge = Stripe::Charge.create({
    amount: (@product.price*100).to_i,
    currency: 'eur',
    source: params[:source]},
    {:stripe_account => @connect.stripe_user_id})
  
    flash[:success] = "Product purchased"
    redirect_to root_path
    
    

  end
  
  
  private 
  
    def product_params
      params.require(:product).permit(:name, :summary, :description, :price, :picture)
    end
    
    def set_product
      @product = Product.find(params[:id])
    end
    
    def set_merchant
      @merchant = @product.merchant
    end
    
    def require_same_user
      if current_user != @product.merchant
        flash[:danger] = "You can only edit your own products"
        redirect_to products_path
      end
    end
    
    private def set_env
      Braintree::Configuration.environment = :sandbox
      Braintree::Configuration.merchant_id = ENV['BT_MERCHANT_ID']
      Braintree::Configuration.public_key = ENV['BT_PUBLIC_KEY']
      Braintree::Configuration.private_key = ENV['BT_PRIVATE_KEY']
      
      @stripe_secret_api_key = ENV['STRIPE_SECRET_API_KEY_TEST']
      @stripe_publishable_api_key = ENV['STRIPE_PUBLISHABLE_API_KEY_TEST']
      @stripe_client_id = ENV['STRIPE_CLIENT_ID_TEST']
      #@stripe_user_id = @connect.stripe_user_id
      #@stripe_user_publishable_api_key = @connect.stripe_publishable_api_key
      
    end
  
end