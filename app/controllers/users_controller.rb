# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, notice: "Profile updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end
  

  private

  def user_params
    params.require(:user).permit(:name, :email, :profile_photo)
  end
end
