class UsersController < ApplicationController
  include Authenticable

  before_action :authenticate!, only: [:index, :update, :destroy]

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)

    if @user.save
      event = {
        title: 'UserCreated',
        data: serialized_user(@user.reload)
      }
      
      Producer.call(event, topic: 'users_created')
      render json: serialized_user(@user.reload), status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      render json: @user.to_h, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.destroy
    head :ok
  end

  private

  def serialized_user(user)
    {
      "public_id": user.id,
      "email": user.email,
      "full_name": user.full_name,
      "role": user.role
    }
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :role, :password)
  end
end