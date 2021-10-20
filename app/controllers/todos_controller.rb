class TodosController < ApplicationController
  before_action :set_todo, only: %i[show destroy]
  before_action :set_todos, only: %i[index create destroy]
  require 'rake'

  def scrape
    agent = Mechanize.new
    url = "https://note.com/pianonoki/n/n6b31db6b5963"
    page = agent.get(url)
    # byebug
    title = page.search('h1.o-noteContentText__title').inner_text
    text_data = page.search('p')
    text_arr = []
    text_data.each{|a|text_arr << a.inner_text}
    text = text_arr.join("\n\n")
    # byebug
    todo = Todo.new(task: title, description: text)
    if todo.save
      Rails.application.load_tasks
      Rake::Task['push:notify'].execute
      Rake::Task['push:notify'].clear
    else
      render json: { status: 'error', data: todo.errors }
    end
  end

  def index
    render json: @todos
  end

  def show
    render json: @todo
  end

  def create
    todo = Todo.new(todo_params)
    if todo.save
      Rails.application.load_tasks
      Rake::Task['push:notify'].execute
      Rake::Task['push:notify'].clear
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
    @todos = Todo.all.order(created_at: :desc).first(20)
  end

  def todo_params
    params.require(:todo).permit(:task, :description)
  end
end