module Authenticable
  def authenticate_user!
    return if current_user.present?

    rander json: { error: 'Unauthenticated' }, status: 401
    
  end

  def current_user
    return @current_user if defined?(@current_user)
    session = UserSession.find(extracted_token[:uuid])

    @current_user = session.user
  end

  def extracted_token
    JwtEncoder.decode(matched_token)
  rescue JWT::DecodeError
    {}
  end

  private

  def matched_token
    result = auth_header&.match(AUTH_TOKEN)
    return if result.blank?

    result[:token]
  end

  def auth_header
    request.env['HTTP_AUTHORIZATION']
  end
end