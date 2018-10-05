class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:create, :edit, :update, :destroy]
  before_action :set_user, only:[:show, :edit, :update]

  def show
    #code
  end

  def edit
    #code
  end

  def update
    #code
  end

  private

  def edit_user_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
