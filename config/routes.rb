# frozen_string_literal: true
Alchemy::JsonApi::Engine.routes.draw do
  resources :pages, only: [:show, :index]
  resources :layout_pages, only: [:show, :index]
end
