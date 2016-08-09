class MerchantsController < ApplicationController
  before_action :set_merchant, only: [:edit, :update, :show]
  before_action :require_same_user, only: [:edit, :update]
  
  def index
   @merchants = Merchant.paginate(page:params[:page], per_page: 3)
   require "stripe"
    Stripe.api_key = "sk_test_KNQxI3UCqUgrZIA5sK2cLvM9"

    @account_list = Stripe::Account.list(:limit => 10)

    

  end
  
  def new 
    @merchant = Merchant.new
  end  
  
  def create
    @merchant = Merchant.new(merchant_params)
    if @merchant.save
      flash[:success] = "Your account has been created successfully"
      session[:merchant_id] = @merchant.id
      redirect_to products_path
    else
      render 'new'
    end
  end
  
  def edit

  end

  def update
    if @merchant.update(merchant_params)
      flash[:success] = "Your profile has been updated successfully"
      redirect_to merchant_path(@merchant)
    else
      render 'edit'
    end
  end
  
  def show
    #@products = @merchant.products.paginate(page: params[:page], per_page: 3)
    @products = @merchant.products
  end
  
  
  private
    def merchant_params
      params.require(:merchant).permit(:merchantname, :email, :password)
    end
    
    def set_merchant
      @merchant = Merchant.find(params[:id])
    end
    
    def require_same_user
      if current_user != @merchant
        flash[:danger] = "You can only edit your own profile"
        redirect_to root_path
      end
    end

end