Rails.application.routes.draw do
  get "/:url" => "todos#scrape"
  get "/new" => "todos#new"
  post '/callback' => 'line_notify#callback'
  get '/push' => 'line_notify#push'
  resources :todos
end