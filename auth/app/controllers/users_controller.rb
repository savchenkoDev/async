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
      event = {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_name: 'UserCreated',
        event_time: Time.current.to_s,
        producer: 'user_service',
        data: @user.to_h
      }
      registry = SchemaRegistry.validate_event(event, 'user.created')

      if registry.success?
        Producer.produce_sync(payload: event.to_json, topic: 'users-stream')
      else
        raise 'InvalidEventError'
      end
    rescue ActiveRecord::Rollback, InvalidEventError
      render json: @user.errors.messages, status: 422
    end
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      event = {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_name: 'UserChanged',
        event_time: Time.current.to_s,
        producer: 'user_service',
        data: @user.to_h
      }
      registry = SchemaRegistry.validate_event(event, 'user.created')
      if registry.success?
        Producer.produce_sync(payload: event.to_json, topic: 'users-stream')
      else
        raise 'InvalidEventError'
      end

      if user_params[:role].present?
        event = {
          event_id: SecureRandom.uuid,
          event_version: 1,
          event_name: 'UserRoleUpdated',
          event_time: Time.current.to_s,
          producer: 'user_service',
          data: @user.to_h
        }
        registry = SchemaRegistry.validate_event(event, 'user.created')
        if registry.success?
          Producer.produce_sync(payload: event.to_json, topic: 'users')
        else
          raise 'InvalidEventError'
        end
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
      data: { public_id: @user.public_id}
    }
    Producer.produce_sync(payload: event.to_json, topic: 'users-stream')
    head :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :role, :password)
  end
end