class MerchantsController < ApplicationController
  before_action :set_env
  before_action :set_merchant, only: [:edit, :update, :show]
  before_action :require_same_user, only: [:edit, :update]
  before_action :require_admin_user, only: [:index]
  
  
  def index
   @merchants = Merchant.all
   require "stripe"
  
   Stripe.api_key = @stripe_secret_api_key

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
      redirect_to merchant_path(@merchant)
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
    
    def require_admin_user
      if current_user.merchantname != 'admin'
        flash[:danger] = "Log in as admin to view this page"
        redirect_to login_path
      end
    end
    
    private def set_env
      @stripe_secret_api_key = ENV['STRIPE_SECRET_API_KEY_TEST']
      @stripe_publishable_api_key = ENV['STRIPE_PUBLISHABLE_API_KEY_TEST']
      @stripe_client_id = ENV['STRIPE_CLIENT_ID_TEST']
    end

end