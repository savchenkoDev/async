class AccountsController < ActionController::Base
  include Authenticable

  def index
    if %w(admin accountant).include?(current_user.role)
      @accounts = Account.all
    else
      @accounts = Account.find_by(user_id: current_user_id)
    end

    render json: { accounts: @accounts }
  end

  def show
    @account = Account.find(params[:id])

    render json: { audits: @account.audits }
  end
end
