Rails.application.routes.draw do
  mount Alchemy::JsonApi::Engine => "/jsonapi/"
end
