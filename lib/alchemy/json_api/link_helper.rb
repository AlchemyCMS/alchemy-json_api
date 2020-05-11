# frozen_string_literal: true
module Alchemy
  module JsonApi
    module LinkHelper
      def alchemy_link(path_base, object)
        return unless object

        if Rails.application.routes.default_url_options[:host]
          Alchemy::Engine.routes.url_helpers.public_send("#{path_base}_url", object)
        else
          Alchemy::Engine.routes.url_helpers.public_send("#{path_base}_path", object)
        end
      end
    end
  end
end
