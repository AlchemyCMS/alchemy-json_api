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
        render html: swagger_ui_html.html_safe
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

      def swagger_ui_html
        spec_url = alchemy_json_api.openapi_path(format: :json)
        <<~HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <title>Alchemy JSON:API Documentation</title>
            <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
            <style>html { box-sizing: border-box; } *, *::before, *::after { box-sizing: inherit; }</style>
          </head>
          <body>
            <div id="swagger-ui"></div>
            <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
            <script>
              SwaggerUIBundle({
                url: "#{spec_url}",
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
                layout: "BaseLayout"
              });
            </script>
          </body>
          </html>
        HTML
      end
    end
  end
end
