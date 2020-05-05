Alchemy::JsonApi::Engine.routes.draw do
  resources :pages, only: [:show, :index]
end
