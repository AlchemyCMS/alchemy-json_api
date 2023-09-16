# frozen_string_literal: true
module Alchemy
  module JsonApi
    module PageClassMethodsExtension
      def ransackable_attributes(_auth_object = nil)
        super | %w[page_layout]
      end

      def ransackable_associations(_auth_object = nil)
        super | %w[public_version]
      end
    end
  end
end
