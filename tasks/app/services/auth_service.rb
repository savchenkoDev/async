module AuthService
  extend self

  def self.auth(header)
    response = connection.get('/auth', {}, { 'Authorization' => header })
    JSON.parse(response.body)['public_id']
  end

  private

  def connection
    @connection ||= Faraday.new(
      url: Settings.auth.url,
      headers: {'Content-Type' => 'application/json'}
    )
  end
end