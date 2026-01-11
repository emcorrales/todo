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
    target_position = reorder_params[:position]
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
    old_position = task.position
    user_tasks = current_user.tasks.ordered

    # When reordering, the task is supposed to use an existing position to
    # replace or calculate it's next position.
    if user_tasks.where("position = ?", target_position).exists?

      # The task is going down the TODO list.
      if target_position > old_position

        max_possible_position = target_position.floor + 1

        highest_position = user_tasks
          .where(position: target_position..max_possible_position)
          .maximum(:position)

        offset = (max_possible_position - highest_position)/2.0

        new_position = highest_position + offset

        task.update(position: new_position)
      end

      if target_position < old_position

        next_task = user_tasks.where(position: target_position..target_position - 1).
        task.update(position: target_position - 0.5) if not next_task
        task.update(position: target_position - (next_task.position + target_position)/2) if next_task
      end
    else
      task.update(position: target_position)
    end
  end
end
