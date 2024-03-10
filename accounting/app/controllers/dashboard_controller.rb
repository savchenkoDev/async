class DashboardController < ActionController::Base
  include Authenticable

  def index
    daily_results = Task.select("SUM(assign_cost) AS assign, SUM(finish_cost) AS finish, status, date_trunc('day', tasks.created_at) AS date")
        .group(:date, :status, :id)

    response = daily_results.map do |day_r|
      {
        date: day_r.date.strftime('%d.%m.%Y'),
        assign: day_r.assign.to_f,
        finish: day_r.finish.to_f,
        total: day_r.assign.to_f - day_r.finish.to_f
      }
    end

    render json: response
  end

  def show
    @account = Account.find(params[:id])

    render json: { audits: @account.audits }
  end
end
