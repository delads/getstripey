class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :show, :like, :destroy]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update]
  
  def destroy
    Product.find(params[:id]).destroy
    flash[:success] = "Product deleted"
    redirect_to products_path
  end

  def index
    @products = Product.paginate(page:params[:page], per_page: 4)
  end
  
  def show

  end
  
  def new
    @product = Product.new
  end
  
  def create
    @product = Product.new(product_params)
    @product.merchant = current_user
    
    if @product.save
      flash[:success] = "Your product was uploaded successfully!"
      redirect_to products_path
      
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
      params.require(:product).permit(:name, :summary, :description, :picture)
    end
    
    def set_product
      @product = Product.find(params[:id])
    end
    
    def require_same_user
      if current_user != @product.merchant
        flash[:danger] = "You can only edit your own products"
        redirect_to products_path
      end
    end
    
end
