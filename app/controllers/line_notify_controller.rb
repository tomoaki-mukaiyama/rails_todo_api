class LineNotifyController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'rake'
  # callbackアクションのCSRFトークン認証を無効
  # protect_from_forgery :except => [:callback]

  def client
    client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          reply_token = event['replyToken']
          request_data = event.message['text']
          case request_data
          when /all/i, /あ/
            arr = []
            todos = Todo.all
            todos.each do |data|
              arr << data.id.to_s + "." + data.task + "\n"
            end
            response_data = arr.join
          when /count/, /か/
            response_data = Todo.all.count
          else
            begin 
              todo_data = Todo.find(request_data.to_i)
              response_data = "#{todo_data.task}\n#{todo_data.description}"
            rescue => e
              response_data = e.message
              response_data
            end
            response_data
          end
          message = {
            type: 'text',
            text: response_data
          }
          response = client.reply_message(reply_token, message)
          response
        end
      end
    }
    
    head :ok
  end
  
  def push
    Rails.application.load_tasks
    Rake::Task['push:notify'].execute
    Rake::Task['push:notify'].clear
  end
end