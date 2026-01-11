class TasksController < ApplicationController
  include Authenticable

  before_action :set_task, only: [ :show, :update, :destroy, :reorder ]

  def index
    @tasks = current_user.tasks.order(position: :asc)
    render json: @tasks, status: :ok
  end

  def create
    @task = current_user.tasks.build(task_params)
    @task.position = current_user.tasks.maximum(:position).to_i + 1

    if @task.save
      render json: @task, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @task, status: :ok
  end

  def update
    if @task.update(task_params)
      render json: @task, status: :ok
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    render json: { message: "Task deleted successfully" }, status: :ok
  end

  def reorder
    new_position = reorder_params[:position]
    reorder_task(@task, new_position)
    render json: @task, status: :ok
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end

  def reorder_params
    params.require(:task).permit(:position)
  end

  def reorder_task(task, new_position)
    old_position = task.position
    user_tasks = current_user.tasks.ordered

    # Check if the new position is already taken
    # and do not use it if it already exists.
    if user_tasks.where("position = ?", new_position).exists?

      puts "meow #{new_position} #{old_position}"

      if new_position > old_position

        # Get last task between new_position and old_position.
        next_task = user_tasks.where(position: new_position..new_position.ceil).last

        # Insert right after new_position because there have been no other inserted tasks after it.
        task.update(position: new_position + 0.5) if not next_task
        # Insert between new_position and the previous inserted task position.
        task.update(position: new_position + (next_task.position - new_position)/2) if next_task
      end

      if new_position < old_position

        next_task = user_tasks.where(position: new_position..new_position - 1).
        task.update(position: new_position - 0.5) if not next_task
        task.update(position: new_position - (next_task.position + new_position)/2) if next_task
      end
    else
      puts "hello"
      task.update(position: new_position)
    end
  end
end
