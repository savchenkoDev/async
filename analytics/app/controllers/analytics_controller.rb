class AnalyticsController < ActionController::Base
  include Authenticable

  def index
    response = {
      manager_profit: Profit.where(date: Date.current).sum(:amount),
      debtor_count: Account.where('balance < 0').count
    }

    render json: response
  end
end
