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

      private

      def render_jsonapi_internal_server_error(exception)
        log_error(exception)
        super
      end

      def log_error(exception)
        logger = Rails.logger
        return unless logger

        message = +"\n#{exception.class} (#{exception.message}):\n"
        message << exception.annotated_source_code.to_s if exception.respond_to?(:annotated_source_code)
        message << "  " << exception.backtrace.join("\n  ")
        logger.fatal("#{message}\n\n")
      end
    end
  end
end
