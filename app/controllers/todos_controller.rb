class TodosController < ApplicationController
  before_action :set_todo, only: :show
  def index
    todos = Todo.all.order(created_at: :desc)
    render json: todos
  end

  def show
    render json: @todo
  end

  def create
    todo = Todo.new(todo_params)
    if todo.save
      render json: { status: 'success', data: todo }
    else
      render json: { status: 'error', data: todo.errors }
    end
  end

  private
  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:task, :description)
  end
end