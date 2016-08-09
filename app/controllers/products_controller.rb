class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :show, :like, :destroy]
  before_action :require_same_user, only: [:edit, :update]
  before_action :set_merchant, only: [:show]
  #skip_before_action :verify_authenticity_token, only: [:pay]
  
  
  def pay

    @product = Product.find(params[:product_id])
    @connect = Connect.where("merchant_id = ?",@product.merchant).first
    
    Rails.logger.debug("ProductsController: #{@connect.inspect}")
    Rails.logger.debug("ProductsController: #{params}")

 
    Stripe.api_key = "sk_test_KNQxI3UCqUgrZIA5sK2cLvM9"
    token = params[:stripeToken]
    # Create the charge on Stripe's servers - this will charge the user's card
        Stripe::Charge.create({
        :amount => (@product.price*100).to_i,
        :currency => "eur",
        :source => token,
        :application_fee => 100 # amount in cents
      }, {:stripe_account => "acct_18fFClKtyHXC0lP5" })

      flash[:success] = "Product purchased"
      redirect_to root_path
  end
  
  def destroy
    Product.find(params[:id]).destroy
    flash[:success] = "Product deleted"
    redirect_to merchants_path
  end

  def index
    @products = Product.paginate(page:params[:page], per_page: 4)
  end
  
  def show
    
    
    
    @products = @merchant.products.paginate(page: params[:page], per_page: 3)
    @product_count = @merchant.products.count
    
    @connect = Connect.where("merchant_id = ?",@merchant).first
  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(product_params)
    @product.merchant = current_user
    
    if @product.save
      flash[:success] = "Your product was uploaded successfully!"
      redirect_to merchants_path
      
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
    
    def require_same_user
      if current_user != @product.merchant
        flash[:danger] = "You can only edit your own products"
        redirect_to products_path
      end
    end
    
end
