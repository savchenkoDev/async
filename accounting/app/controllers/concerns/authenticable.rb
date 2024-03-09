module Authenticable
  def authenticate_user!
    return if current_user.present?

    render json: { error: 'Unauthenticated' }, status: 401
  end

  def current_user
    User.find_by(public_id: current_user_id)
  end

  private

  def current_user_id
    AuthService.auth(request.env['HTTP_AUTHORIZATION'])
  end
end