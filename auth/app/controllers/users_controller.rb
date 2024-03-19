class UsersController < ApplicationController
  include Authenticable

  before_action :authenticate_user!, only: [:index, :update, :destroy]

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)

    User.transaction do
      @user.save
      Producers::Users::CreatedV1.produce(object: @user)
    rescue ActiveRecord::Rollback, BaseProducer::InvalidEventError
      render json: @user.errors.messages, status: 422
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      Producers::Users::ChangedV1.produce(object: @user)
      Producers::Users::RoleChangedV1.produce(object: @user) if user_params[:role].present?
      end
      render json: @user.to_h, status: 201
    else
      render json: @user.errors.messages, status: 422
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.destroy
    Producers::Users::RoleChangedV1.produce(object: @user) if user_params[:role].present?
    head :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :role, :password)
  end
end