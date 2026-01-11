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
    target_position = reorder_params[:position].to_f
    reorder_task(@task, target_position)
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

  def reorder_task(task, target_position)
    user_tasks = current_user.tasks.ordered
    new_position = target_position

    if user_tasks.where("position = ?", target_position).exists?
        ceiling_position = target_position.floor + 1

        nearest_position = user_tasks
          .where(position: target_position.next_float..ceiling_position)
          .minimum(:position)

        available_space = 0
        if nearest_position
          available_space = (nearest_position - target_position)
        else
          available_space = (ceiling_position - target_position)
        end
        new_position += (available_space/2.0)
    end

    task.update(position: new_position)
  end
end
