class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show ]
  before_action :set_seller_product, only: %i[ edit update destroy ]
  before_action :authenticate_user!, only: %i[new create edit update destroy]

  def index
    if params[:query].present?
      @products = Product.left_joins(:rich_text_description)
      .where("products.title ILIKE :query OR action_text_rich_texts.body ILIKE :query",
      query: "%#{params[:query]}%")
    else
      @products = Product.all
    end
  end


  def search_suggestions
    if params[:query].present?
      products = Product.left_joins(:rich_text_description)
      .where("products.title ILIKE :query OR action_text_rich_texts.body ILIKE :query",
      query: "%#{params[:query]}%")
      .limit(5)
      render json: products.pluck(:title)
    else
      render json: []
    end
  end


  def show
    @reviews = @product.reviews.order("created_at DESC")
    @new_review = @product.reviews.new(user_id: current_user&.id)
  end

  def buy
  end

  def new
    @product = current_user.products.new
  end

  def edit
  end

  def create
    @product = current_user.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_seller_product
      @product = current_user.products.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, alert: "Product not found!" and return
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:title, :description, :price, :seller_id, images: [])
    end
end
