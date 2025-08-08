class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[ destroy ]
  before_action :authenticate_user!

  
  # POST /cart_items or /cart_items.json
  def create
    @cart = Cart.find_or_create_by(user_id: current_user.id)
    @product = Product.find(params[:product_id])
    @cart.cart_items.create!(product:@product) if @cart.products.exclude?(@product)
  end

  # DELETE /cart_items/1 or /cart_items/1.json
  def destroy
    @cart_item.destroy!

    respond_to do |format|
      format.html { redirect_to cart_items_path, status: :see_other, notice: "Cart item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_item
      @cart_item = CartItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def cart_item_params
      params.expect(cart_item: [ :cart_id, :product_id ])
    end
end
