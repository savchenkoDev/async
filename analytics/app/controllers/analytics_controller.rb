class AnalyticsController < ActionController::Base
  include Authenticable

  def index
    daily_tasks = Task.where('created_at >= ?', Date.current.beginning_of_day)
    assign = daily_tasks.where(status: 'opened').sum(:assign_cost)
    finish = daily_tasks.where(status: 'finished').sum(:finish_cost)
    response = {
      debtor_count:  Account.where('balance < 0').count,
      management_profit: assign - finish,
      max_cost: daily_tasks.maximum(:finish_cost)
    }

    render json: response
  end
end
