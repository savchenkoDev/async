class AccountMailer
  def self.send_day_result(account)
    message = "Day result: #{account.balance.to_d}"
  end
end