# frozen_string_literal: true

module Alchemy
  module JsonApi
    class BaseController < ::ApplicationController
      include Alchemy::ControllerActions
      include Alchemy::AbilityHelper
      include JSONAPI::Fetching
      include JSONAPI::Errors
      include JSONAPI::Filtering
      include JSONAPI::Pagination

      rescue_from(
        CanCan::AccessDenied,
        with: :render_jsonapi_unauthorized
      )

      private

      def render_jsonapi_internal_server_error(exception)
        log_error(exception)
        super
      end

      def log_error(exception)
        logger = Rails.logger
        return unless logger

        message = "\n#{exception.class} (#{exception.message}):\n"
        message << exception.annotated_source_code.to_s if exception.respond_to?(:annotated_source_code)
        message << "  " << exception.backtrace.join("\n  ")
        logger.fatal("#{message}\n\n")
      end

      def render_jsonapi_unauthorized(exception)
        error = {status: "401", title: Rack::Utils::HTTP_STATUS_CODES[401]}
        render jsonapi_errors: [error], status: :unauthorized
      end
    end
  end
end
