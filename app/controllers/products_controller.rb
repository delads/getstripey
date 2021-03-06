class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :show, :like, :destroy]
  before_action :require_same_user, only: [:edit, :update]
  before_action :set_merchant, only: [:show, :destroy]
  before_action :set_env
  #skip_before_action :verify_authenticity_token, only: [:pay]
  
    TRANSACTION_SUCCESS_STATUSES = [
    Braintree::Transaction::Status::Authorizing,
    Braintree::Transaction::Status::Authorized,
    Braintree::Transaction::Status::Settled,
    Braintree::Transaction::Status::SettlementConfirmed,
    Braintree::Transaction::Status::SettlementPending,
    Braintree::Transaction::Status::Settling,
    Braintree::Transaction::Status::SubmittedForSettlement,
  ]
  
  def create_customer_android

    stripe_version = params['api_version']
    customer_id = customer_number
    key = Stripe::EphemeralKey.create(
      {customer: customer_id},
      {stripe_version: stripe_version}
    )
    
    render :json=> key.to_json

  end
  
  def payandroid
    @product = Product.find(params[:product_id])
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    
    Rails.logger.debug("ProductsController: #{@connect.inspect}")
    Rails.logger.debug("ProductsController: #{params}")
    
    
    Stripe.api_key = @stripe_secret_api_key
    token = params[:stripeToken]
    # Create the charge on Stripe's servers - this will charge the user's card
    
    message = "success"
    
    begin
        Stripe::Charge.create({
        :amount => (@product.price*100).to_i,
        :currency => "eur",
        :source => token,
        :application_fee => 100 # amount in cents
      }, {:stripe_account => @connect.stripe_user_id })
      
    rescue Stripe::CardError => e
      message = e.to_s
    end
    
      render :json => message.to_json
  end
  

  def pay_3ds
    @product = Product.find(params[:product_id])
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    customer_return_url = url_for("http://" + request.host + "/confirmation") 
    
    Stripe.api_key = @stripe_secret_api_key
    sourceId = params[:stripeSource]
    
    Rails.logger.debug("3DS ProductsController: sourceId : " + sourceId);
    
    source = Stripe::Source.create({
      amount: (@product.price*100).to_i,
      currency: 'eur',
      type: 'three_d_secure',
      three_d_secure: {card: sourceId,},
      metadata: {getstripey_product_id: params[:product_id],},
      redirect: {return_url: customer_return_url + '?id=' + @product.id.to_s}},
      {stripe_account: @connect.stripe_user_id})
  
    redirect_url = source.redirect.url
    redirect_to redirect_url
  
  end
  
  
  def pay

    @product = Product.find(params[:product_id])
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    
    Rails.logger.debug("ProductsController: #{@connect.inspect}")
    Rails.logger.debug("ProductsController: #{params}")

 
    Stripe.api_key = @stripe_secret_api_key
    token = params[:stripeToken]
    
   # binding.pry
    
    # Create the charge on Stripe's servers - this will charge the user's card
        Stripe::Charge.create(
        {:amount => (@product.price*100).to_i,
         :currency => "eur",
         :source => token,
         :application_fee => 100}, # amount in cents
        {:stripe_account => @connect.stripe_user_id} )

      flash[:success] = "Product purchased"
      redirect_to root_path
  end
  
    def pay_ideal

    @product = Product.find(params[:product_id])
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    
    Rails.logger.debug("ProductsController: #{@connect.inspect}")
    Rails.logger.debug("ProductsController: #{params}")

 
    Stripe.api_key = @stripe_secret_api_key
    token = params[:stripeToken]
    customer_name = params[:customer_name]
    customer_return_url = url_for("http://" + request.host + "/confirmation") 
    
   # binding.pry
    
    
    
    # Create the charge on Stripe's servers - this will charge the user's card
    #    Stripe::Charge.create({
    #    :amount => (@product.price*100).to_i,
    #    :currency => "eur",
    #    :source => token,
    #    :application_fee => 100 # amount in cents
    #  }, {:stripe_account => @connect.stripe_user_id })

    source = Stripe::Source.create({
    amount: (@product.price*100).to_i,
    currency: 'eur',
    type: 'ideal',
    owner: {name: customer_name},
    metadata: {product_id: @product.id.to_s},
    redirect: {return_url: customer_return_url + '?id=' + @product.id.to_s,},
    ideal: {statement_descriptor: 'ORDER AT11990'}},
    {stripe_account: @connect.stripe_user_id})
    
    redirect_url = source.redirect.url
    redirect_to redirect_url

  end

  
  
  
  def pay_braintree
    
    amount = params["amount"] # In production you should not take amounts directly from clients
    # amount = 10
    nonce = params["payment_method_nonce"]

    result = Braintree::Transaction.sale(
      amount: amount,
      payment_method_nonce: nonce,
    )

    if result.success? || result.transaction
      flash[:success] = "Product purchased through Braintree =("
      redirect_to root_path
    else
      error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
      flash[:error] = error_messages
      redirect_to product_path(@product)
    end
  end
  
  def pay_braintree_android
    
    amount = params["amount"] # In production you should not take amounts directly from clients
    nonce = params["payment_method_nonce"]

    result = Braintree::Transaction.sale(
      amount: amount,
      payment_method_nonce: nonce,
    )

    if result.success? || result.transaction
      render :json => "Product purchased through Braintree =("
    else
      error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
       render :json => error_messages
    end
  end
  
  
  
  
  
  def destroy
    Product.find(params[:id]).destroy
    flash[:success] = "Product deleted"
    redirect_to merchant_path(@merchant)
  end

  def index
    @products = Product.paginate(page:params[:page], per_page: 4)
  end
  
  def show
    
    
    
    @products = @merchant.products.paginate(page: params[:page], per_page: 3)
    @product_count = @merchant.products.count
    
    @connect = Connect.where("merchant_id = ?",@merchant).first
    
        
    #Let's kickoff with a braintree token
    @braintree_client_token = Braintree::ClientToken.generate
    
    #Let's make the Stripe user token available also (testing if this should be the platform or the user)
    @stripe_user_publishable_api_key = @connect.stripe_publishable_key
    @stripe_user_id = @connect.stripe_user_id
    
  end
  
  def getbraintreetoken
    #Let's kickoff with a braintree token
    token = Braintree::ClientToken.generate
    render :json => token.to_s
    
  end
  
  
  def new
    @product = Product.new

    
  end
  
  def create
    @product = Product.new(product_params)
    @product.merchant = current_user
    
    if @product.save
      flash[:success] = "Your product was uploaded successfully!"
      redirect_to merchant_path(current_user)
      
    else
      render :new
    end
  end
  

  
  def update

    
    if @product.update(product_params)
      flash[:success] = "Your product was updated successfully!"
      redirect_to  product_path(@product)
    else
      render :edit
    end
    
  end
  
  def like
    like = Like.create(like: params[:like], merchant: current_user, product: @product)
    if(like.valid?)
      flash[:success] = "Your selection was successful"
      redirect_to :back
    else
      flash[:danger] = "You can only like/dislike product once"
      redirect_to :back
    end
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
    
    def set_customer
      customer_number = "1234567"
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
     
      #@stripe_user_publishable_api_key = @connect.stripe_publishable_api_key
      
    end
  
    
end
