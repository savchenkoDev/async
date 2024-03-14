class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    scope = if current_user.admin?
              Task.all
            else
              Task.where(user_id: current_user_id)
            end
    @tasks = scope.paginate(page: params[:page], per_page: params[:per_page])

    render json: { tasks: @tasks }
  end

  def create
    @task = current_user.tasks.new(task_params)

    if @task.save
      Producers::Tasks::CreatedV1.produce(object: @task)
      Producers::Tasks::AssignedV1.produce(object: @task)

      render json: @task.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 201
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      Producers::Tasks::UpdatedV1.produce(object: @task)
      render json: @task.reload.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 422
    end
  end

  def finish
    @task = Task.opened.find(params[:id])
    return render json: { error: 'Unauthorized' }, status: 403 unless current_user_id == @task.user.public_id

    @task.finish!
    Producers::Tasks::FinishedV1.produce(object: @task)

    head :ok
  end

  def shuffle
    @tasks = Task.opened.includes(:user)
    @users = User.where(role: 'popug')

    @tasks.each do |task|
      old_user_id = task.user.public_id
      if task.update(user_id: @users.sample.public_id)
        Producers::Tasks::ShuffledV1.produce(object: task)
      end
    end

    head :ok
  end

  def destroy
    @task = Task.find(params[:id])

    @task.destroy
    event = {
      event_name: 'TaskDeleted',
      data: { public_id: @task.public_id }
    }
    Producers::Tasks::DeletedV1.produce(object: @task)

    head :ok
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :jira_id)
  end
end
