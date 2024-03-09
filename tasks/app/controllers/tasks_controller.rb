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
      event = {
        event_name: 'TaskCreated',
        data: @task.to_h
      }
      Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)
      render json: @task.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 201
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      event = {
        event_name: 'TaskChanged',
        data: @task.to_h
      }
      Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)
      render json: @task.reload.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 422
    end
  end

  def finish
    @task = Task.find(params[:id])
    return render json: { error: 'Unauthorized' }, status: 403 unless current_user_id == @task.user_id

    @task.finish!
    event = {
      event_name: 'TaskFinished',
      data: {
        task_id: @task.public_id,
        cost: @task.cost,
      }
    }
    Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)

    head :ok
  end

  def shuffle
    @tasks = Task.opened.inclues(:user)
    @users = User.where(role: 'popug')

    @tasks.each do |task|
      old_user_id = task.user.public_id
      if task.update(user_id: @users.sample.public_id)
        event = {
          event_name: 'TaskShuffled',
          data: {
            id: task.id,
            old_user_id: old_user_id,
            new_user_id: task.user.public_id
          }
        }
        Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)
      end
    end
  end

  def destroy
    @task = Task.find(params[:id])

    @task.destroy
    event = {
      event_name: 'TaskDeleted',
      data: @task.id
    }
    Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)

    head :ok
  end

  private

  def task_params
    params.require(:task).permit(:title, :description)
  end
end
