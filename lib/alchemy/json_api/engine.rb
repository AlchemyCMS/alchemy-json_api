module Alchemy
  module JsonApi
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy::JsonApi
      config.generators.api_only = true
    end
  end
end
