class AuthController < ApplicationController
  include Authenticable

  def index
    @session = UserSession.find_by(id: extracted_token['uuid'])

    render json: { user_id: @session&.user_id }
  end
end