class ConnectsController < ApplicationController
  before_action :set_env
  before_action :set_merchant
  before_action :set_connect
  before_action :configure_connect
  
  def show
    Stripe.api_key = @stripe_secret_api_key
    begin
      @stripe_account = Stripe::Account.retrieve(@connect.stripe_user_id)
    rescue Exception => exc
      @stripe_account = nil
      #do nothing
      #flash[:danger] = exc.message
    end
  end
 
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
   Stripe.api_key = @stripe_secret_api_key
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

    Stripe.api_key = @stripe_secret_api_key
    
     connect = Connect.where("merchant_id = ?",session[:merchant_id]).first
     @stripe_user_id = connect.stripe_user_id
     is_destroyed = connect.destroy
     
    Rails.logger.debug("ConnectsController: @stripe_user_id  = " + @stripe_user_id )
    
    #Let's now also disconnect from Stripe on their side
    #uri = URI('https://connect.stripe.com/oauth/deauthorize')
    #req = Net::HTTP::Post.new(uri)
    #req.set_form_data('client_id' => @client_id, 'stripe_user_id' => @stripe_user_id)
    
    #res = Net::HTTP.start(uri.hostname, uri.port,
    #:use_ssl => uri.scheme == 'https') do |http|
    #  http.request(req)
    #  Rails.logger.debug("ConnectsController: Request to Stripe  = " + uri.to_s )
    #  Rails.logger.debug("ConnectsController: Response from disconnecting Connected account from Stripe  = " + res.value )
    #end
    
    #http = Net::HTTP.new('connect.stripe.com', 443)
    #http.use_ssl = true
    #path(a.k.a) ->www.mysite.com/some_POST_handling_script.rb'
    #path = '/oauth/deauthorize'
    #data = 'client_id=' + @client_id + '&stripe_user_id=' + @stripe_user_id
    
    #headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}

    #resp = http.post(path, data, headers)
    
    #Rails.logger.debug( 'Code = ' + resp.code )
    #Rails.logger.debug( 'Message = ' + resp.message )
    
    
    #uri = URI.parse("https://connect.stripe.com/oauth/deauthorize")
    #https = Net::HTTP.new(uri.host,uri.port)
    #https.use_ssl = true
    #req = Net::HTTP::Post.new(uri.path)
    #req['client_id'] = @client_id
    #req['stripe_user_id'] = @stripe_user_id
    #res = https.request(req)
    
    #params = {'client_id' => @client_id,
    #            'stripe_user_id' => @stripe_user_id
    #        }
    #uri = URI('https://connect.stripe.com/oauth/deauthorize')
    #https = Net::HTTP.new(uri.host,uri.port)
    #https.use_ssl = true
    #res = https.post_form(uri, params)
    #puts res.body
    
    #uri = URI('https://connect.stripe.com/oauth/deauthorize')
    #res = Net::HTTP.post_form(uri, 'client_id' => @client_id, 'stripe_user_id' => @stripe_user_id, 'client_secret' => @api_key)
    #puts res.body

    #Rails.logger.debug("ConnectsController: Request to Stripe  = " + uri.to_s )
    #Rails.logger.debug("ConnectsController: Response from disconnecting Connected account from Stripe  = " + res.value )
    
    
    http = Net::HTTP.new('connect.stripe.com', 443)
    http.use_ssl = true
    #path(a.k.a) ->www.mysite.com/some_POST_handling_script.rb'
    path = '/oauth/deauthorize'
    data = 'client_id=' + @stripe_client_id + '&stripe_user_id=' + @stripe_user_id + '&client_secret=' + @stripe_secret_api_key
    
    headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}

    resp = http.post(path, data, headers)
    
    Rails.logger.debug( 'Code = ' + resp.code )
    Rails.logger.debug( 'Message = ' + resp.message )
    puts resp.body
    


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
    
    status 200
    
  end

  
  
  private
    def set_merchant
      @merchant = Merchant.find(session[:merchant_id])
    end
    
    def set_connect
      @connect = Connect.where("merchant_id = ?",session[:merchant_id]).first
    end
    
    
    
    def configure_connect
     # config = YAML::load(File.open('config/secrets.yml'))
      
     #  @api_key = config['api_key']
    # @client_id = config['client_id']
  
      options = {
        :site => 'https://connect.stripe.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }
  
      @client = OAuth2::Client.new(@stripe_client_id, @stripe_secret_api_key, options)
    end
    
    
    private def set_env
      @stripe_secret_api_key = ENV['STRIPE_SECRET_API_KEY_TEST']
      @stripe_publishable_api_key = ENV['STRIPE_PUBLISHABLE_API_KEY_TEST']
      @stripe_client_id = ENV['STRIPE_CLIENT_ID_TEST']
    end
end  
