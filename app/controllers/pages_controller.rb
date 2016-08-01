class PagesController < ApplicationController
  def home
    
    redirect_to products_path if logged_in?
    
  end
end