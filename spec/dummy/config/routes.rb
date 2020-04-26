Rails.application.routes.draw do
  mount Alchemy::Engine => "/"
  mount Alchemy::JsonApi::Engine => "/jsonapi/"
end
