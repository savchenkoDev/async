class DailyWorker
  include Sidekiq::Worker

  def perform
    ::Account.includes(:user).where(users: { role: 'popug' }).each do |account|
      next unless account.balance.positive?

      AccountMailer.send_day_result(account)
      account.audits.create(type: 'payout', amount: account.balance)
      account.update(balance: 0)
    end

    object = {
      debtor_count: ::Account.where('balance < 0').count
    }

    # Producers::Analytics::DayResultV1.produce(object: object)
  end
end
