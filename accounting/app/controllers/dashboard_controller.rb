class DashboardController < ActionController::Base
  include Authenticable

  def index
    daily_tasks = Task.where('created_at >= ?', Date.current.beginning_of_day)
    assign = daily_tasks.opened.sum(:assign_cost)
    finish = daily_tasks.finished.sum(:finish_cost)

    response = {
      date: Date.current.strftime('%d.%m.%Y'),
      count: daily_tasks.count,
      assign: assign,
      finish: finish,
      total: assign.to_f - finish.to_f
    }

    render json: response
  end

  def show
    @account = Account.find(params[:id])

    render json: { audits: @account.audits }
  end
end
