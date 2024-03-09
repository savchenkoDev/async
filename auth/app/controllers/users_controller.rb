class UsersController < ApplicationController
  include Authenticable

  before_action :authenticate_user!, only: [:index, :update, :destroy]

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.reload
      event = {
        event_name: 'UserCreated',
        data: @user
      }
      Producer.produce_sync(payload: event.to_json, topic: 'users-stream')

      render json: @user.to_json, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      event = {
        event_name: 'UserChanged',
        data: @user
      }
      Producer.produce_sync(payload: event.to_json, topic: 'users-stream')

      if user_params[:role].present?
        event = {
          event_name: 'UserRoleUpdated',
          data: @user
        }
        Producer.produce_sync(payload: event.to_json, topic: 'users')
      end

      render json: @user.to_json, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.destroy
    event = {
      event_name: 'UserDeleted',
      data: @user
    }
    Producer.produce_sync(payload: event.to_json, topic: 'users-stream')
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