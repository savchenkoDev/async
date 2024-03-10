class DailyWorker
  include Sidekiq::Worker

  def perform
    Account.includes(:user).where(users: { role: 'popug' }).each do |account|
      next unless account.balance.positive?

      AccountMailer.send_day_result(account)
      account.audits.create(type: 'payout', amount: account.balance)
      account.update(balance: 0)
    end
  end
end
