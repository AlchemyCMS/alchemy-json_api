# frozen_string_literal: true

require "yaml"
require "json"

module Alchemy
  module JsonApi
    class OpenapiController < ::ApplicationController
      def show
        render json: spec
      end

      def docs
        @spec_url = alchemy_json_api.openapi_path(format: :json)
        render layout: false
      end

      private

      def spec
        @spec ||= JSON.generate(
          YAML.safe_load_file(
            Alchemy::JsonApi::Engine.root.join("docs", "openapi.yml"),
            permitted_classes: [Date, Time]
          )
        )
      end
    end
  end
end
