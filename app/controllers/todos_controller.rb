class TodosController < ApplicationController
  before_action :set_todo, only: %i[show destroy]
  before_action :set_todos, only: %i[index create destroy]

  def index
    render json: @todos
  end

  def show
    render json: @todo
  end

  def create
    todo = Todo.new(todo_params)
    if todo.save
      render json: { status: 'success', data: @todos }
    else
      render json: { status: 'error', data: todo.errors }
    end
  end
  
  def destroy
    if @todo.destroy
      render json: { status: 'success', data: @todos }
    else
      render json: { status: 'error', data: @todo.errors }
    end
  end

  private
  def set_todo
    @todo = Todo.find(params[:id])
  end

  def set_todos
    @todos = Todo.all.order(created_at: :desc)
  end

  def todo_params
    params.require(:todo).permit(:task, :description)
  end
end