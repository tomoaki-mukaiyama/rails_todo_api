Rails.application.routes.draw do
  resources :todos
  post "/todos/scrape" => "todos#scrape"
end