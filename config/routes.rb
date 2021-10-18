Rails.application.routes.draw do
  get "/new" => "todos#new"
  post '/callback' => 'line_notify#callback'
  get '/push' => 'line_notify#push'
  resources :todos
end
