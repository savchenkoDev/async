class UserSessionsController < ApplicationController
  include Authenticable

  def create
    if user&.valid_password?(session_params[:password])
      @session = user.sessions.create
      token = JwtEncoder.encode(uuid: @session.id)

      render json: { meta: { token: token } }, status: 201
    else
      render json: { error: 'Email or Password is invalid' }, status: 422
    end
  end

  def destroy
    @session = UserSession.find(extracted_token['uuid'])

    @session.destroy
    head :ok
  end

  private

  def user
    @user ||= User.find_by(email: session_params[:email])
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end