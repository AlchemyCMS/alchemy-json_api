# frozen_string_literal: true
module Alchemy
  module JsonApi
    class BaseController < ::ApplicationController
      include Alchemy::ControllerActions
      include JSONAPI::Fetching
      if Rails.env.production?
        include JSONAPI::Errors
      end
      include JSONAPI::Filtering
      include JSONAPI::Pagination
    end
  end
end
