class TodosController < ApplicationController
  before_action :set_todo, only: %i[show destroy]
  before_action :set_todos, only: %i[index create destroy]
  require 'rake'

  def scrape
    begin
      agent = Mechanize.new
      url = params[:todo][:task]
      page = agent.get(url)
      doc = Nokogiri::HTML.parse(page.body)
      body = doc.search("div.note-common-styles__textnote-body")
      elements = body.children
      arr = elements.map do |elem|
        if elem.name == "figure"
          if elem.children[0].children.children[0].values[5] != nil
            p "note url get"
            elem = elem.children[0].children.children[0].values[5]
          else
            elem.to_s.split(" ").each do |a|
              if a[0..3] == "href"
                elem = a[6..a.length - 2]
                p "外部url ----------------------------------------------------------------------------"
                p elem
              end
            end
          end
        else
          elem = elem.text
        end
        elem
      end
      title = page.search('h1.o-noteContentText__title').inner_text
      text = arr.join("\n\n")
      text += "\n\nこの記事のURL ➡︎ " + url
      todo = Todo.new(task: title, description: text)
      
      # note記事をdbに保存 & lineにpush
      if todo.save
        # Rails.application.load_tasks
        # Rake::Task['push:notify'].execute
        # Rake::Task['push:notify'].clear
      else
        render json: { status: 'error', data: todo.errors }
      end
    rescue => e
      p"-------------raised error-------------------------------------"
      p e
      p"--------------------------------------------------------------"
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
      # render json: { status: 'success', data: @todos }
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