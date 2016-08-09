class ConnectsController < ApplicationController
  before_action :set_merchant
  before_action :set_connect
  before_action :configure_connect
 
  def authorize
    params = {
      :scope => 'read_write'
    }

    # Redirect the user to the authorize_uri endpoint
    url = @client.auth_code.authorize_url(params)
    redirect_to url
  end
 
  def new
    account_code = params[:code]
    stripe_response = @client.auth_code.get_token(account_code, :params => {:scope => 'read_write'})
    
    stripe_user_id = stripe_response['stripe_user_id']

   connect = Connect.new
   connect.merchant = @merchant
   connect.stripe_user_id = stripe_response['stripe_user_id']
   connect.stripe_publishable_key = stripe_response['stripe_publishable_key']
   connect.access_token = stripe_response.token
   
   #Let's get the email associated with this Stripe account
   Stripe.api_key = @api_key
   account = Stripe::Account.retrieve(stripe_user_id)
   connect.email = account["email"]

    redirect_to connect_path(@merchant)
    
    if connect.save
      flash[:success] = "You have now connected your Store to Stripe! : " 
      
    else
      flash[:danger] = "There was a problem connecting your Store to Stripe. Please try again later"
      
    end
    
    @connect = Connect.where("merchant_id = ?",session[:merchant_id]).first
  end
  
  def destroy

    is_destroyed = Connect.where("merchant_id = ?",session[:merchant_id]).destroy_all
    redirect_to connect_path(@merchant)
     
   if is_destroyed
      flash[:success] = "You have now disconnected your Store from Stripe!"
      
   else
      flash[:danger] = "There was a problem disconnecting your Store from Stripe. Please try again later"
   end
  end
  
  def disconnect
    connect = Connect.where("stripe_user_id = ?",params[:user_id]).first
    merchant = connect.merchant_id
    is_destroyed = connect.destroy

    redirect_to connect_path(merchant)
     
   if is_destroyed
      flash[:success] = "You have now disconnected your Store from Stripe!"
      
   else
      flash[:danger] = "There was a problem disconnecting your Store from Stripe. Please try again later"
   end
    
    
  end
  
  def webhook
    Rails.logger.debug("ConnectsController: Webhook called with user_id = " + params[:user_id] )
    Connect.where("stripe_user_id = ?",params[:user_id]).destroy_all
  end

  
  
  private
    def set_merchant
      @merchant = Merchant.find(session[:merchant_id])
    end
    
    def set_connect
      @connect = Connect.where("merchant_id = ?",session[:merchant_id]).first
    end
    
    def configure_connect
      config = YAML::load(File.open('config/secrets.yml'))
      
      @api_key = config['api_key']
      client_id = config['client_id']
  
      options = {
        :site => 'https://connect.stripe.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }
  
      @client = OAuth2::Client.new(client_id, @api_key, options)
    end
end  
