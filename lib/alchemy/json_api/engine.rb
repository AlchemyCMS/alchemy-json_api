# frozen_string_literal: true

require "jsonapi"
# Fixes jsonapi-serializer's `lazy_load_data` for nested includes. Loaded at
# boot (rather than via an autoloader) because it patches a gem constant.
require "alchemy/json_api/patches/fast_jsonapi/serialization_core_patch"

module Alchemy
  module JsonApi
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy::JsonApi
      config.generators.api_only = true

      JSONAPI::Rails.install!
    end
  end
end
