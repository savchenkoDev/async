class AuthController < ApplicationController
  def index
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