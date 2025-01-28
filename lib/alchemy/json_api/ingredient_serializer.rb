# frozen_string_literal: true

module Alchemy
  module JsonApi
    module IngredientSerializer
      def self.included(klass)
        klass.attributes(
          :role,
          :value,
          :created_at,
          :updated_at
        )

        klass.attribute :deprecated, &:deprecated?
      end
    end
  end
end
