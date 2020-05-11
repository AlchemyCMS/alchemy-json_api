require "jsonapi"

module Alchemy
  module JsonApi
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy::JsonApi
      config.generators.api_only = true

      JSONAPI::Rails.install!
    end
  end
end
