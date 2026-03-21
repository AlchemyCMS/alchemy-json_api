# frozen_string_literal: true

Alchemy::JsonApi::Engine.routes.draw do
  get "openapi", to: "openapi#show", defaults: {format: :json}, as: :openapi
  get "docs", to: "openapi#docs", constraints: ->(_req) { Rails.env.development? }

  resources :pages, only: [:index]
  get "pages/*path" => "pages#show", :as => :page
  resources :layout_pages, only: [:index]
  get "layout_pages/*path" => "layout_pages#show", :as => :layout_page
  resources :nodes, only: [:index]

  namespace :admin do
    get "pages/*path" => "pages#show", :as => :page
    resources :layout_pages, only: [:index]
    get "layout_pages/*path" => "layout_pages#show", :as => :layout_page
  end
end
