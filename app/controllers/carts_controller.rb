class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  # GET /carts/1 or /carts/1.json
  def show
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = current_user.cart
      redirect_to :root unless @cart
    end

    # Only allow a list of trusted parameters through.
    def cart_params
      params.expect(cart: [ :user_id ])
    end
end
