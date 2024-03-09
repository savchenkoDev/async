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
        data: @user.to_h
      }
      Producer.produce_sync(payload: event.to_json, topic: 'users-stream')

      render json: @user.to_h, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      event = {
        event_name: 'UserChanged',
        data: @user.to_h
      }
      Producer.produce_sync(payload: event.to_json, topic: 'users-stream')

      if user_params[:role].present?
        event = {
          event_name: 'UserRoleUpdated',
          data: @user.to_h
        }
        Producer.produce_sync(payload: event.to_json, topic: 'users')
      end

      render json: @user.to_h, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.destroy
    event = {
      event_name: 'UserDeleted',
      data: @user.public_id
    }
    Producer.produce_sync(payload: event.to_json, topic: 'users-stream')
    head :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :role, :password)
  end
end