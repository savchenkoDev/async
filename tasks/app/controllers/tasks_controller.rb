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
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_name: 'TaskCreated',
        event_time: Time.current.to_s,
        producer: 'tasks_service',
        data: @task.to_h
      }
      registry = SchemaRegistry.validate_event(event, 'task.created')
      if registry.success?
        Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)
      else
        raise 'InvalidEventError'
      end
      
      @task.produce_assign_event
      render json: @task.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 201
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      event = {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_name: 'TaskCreated',
        event_time: Time.current.to_s,
        producer: 'tasks_service',
        data: @task.to_h
      }
      registry = SchemaRegistry.validate_event(event, 'task.changed')
      if registry.success?
        Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)
      else
        raise 'InvalidEventError'
      end
      render json: @task.reload.to_h, states: 201
    else
      render json: { errors: @task.errors }, states: 422
    end
  end

  def finish
    @task = Task.opened.find(params[:id])
    return render json: { error: 'Unauthorized' }, status: 403 unless current_user_id == @task.user.public_id

    @task.finish!
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_name: 'TaskFinished',
      event_time: Time.current.to_s,
      producer: 'tasks_service',
      data: {
        public_id: @task.public_id,
        user_id: @task.user.public_id,
        assign_cost: @task.assign_cost,
        finish_cost: @task.finish_cost,
      }
    }
    registry = SchemaRegistry.validate_event(event, 'task.finished')
    if registry.success?
      Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)
    else
      raise 'InvalidEventError'
    end

    head :ok
  end

  def shuffle
    @tasks = Task.opened.includes(:user)
    @users = User.where(role: 'popug')

    @tasks.each do |task|
      old_user_id = task.user.public_id
      if task.update(user_id: @users.sample.public_id)
        event = {
          event_name: 'TaskShuffled',
          data: {
            public_id: task.public_id,
            old_user_id: old_user_id,
            new_user_id: task.user.public_id
          }
        }
        Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)
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
    Producer.produce_async(topic: 'tasks-stream', payload: event.to_json)

    head :ok
  end

  private

  def task_params
    params.require(:task).permit(:title, :description)
  end
end
