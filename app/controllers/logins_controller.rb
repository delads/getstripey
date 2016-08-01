class LoginsController < ApplicationController
  
  def new
    
  end
  
  def create
    merchant = Merchant.find_by(email: params[:email])
    if merchant && merchant.authenticate(params[:password])
      session[:merchant_id] = merchant.id
      flash[:success] = "You are logged in"
      redirect_to products_path
      
    else
      
      flash.now[:danger] = "Your email address or password does not match"
      render 'new'
      
    end
  end
  
  def destroy
    session[:merchant_id] = nil
    flash[:success] = "You have logged out"
    redirect_to root_path
  end
  
end