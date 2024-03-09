class AuthController < ApplicationController
  include Authenticable

  def index
    @session = UserSession.find_by(id: extracted_token['uuid'])

    render json: { public_id: @session&.user.public_id }
  end
end
