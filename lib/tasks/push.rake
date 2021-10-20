namespace :push do
  desc "push"
  task notify: :environment do
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    def text
      "タイトル：#{Todo.last.task}\n\n 説明：#{Todo.last.description}"
    end
  
    message = {
      type: 'text',
      text: text  
    }
    response = client.push_message(ENV["USER_ID"], message)
    p response  
  end  
end
