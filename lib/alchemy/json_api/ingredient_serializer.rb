# frozen_string_literal: true

module Alchemy
  module JsonApi
    module IngredientSerializer
      def self.included(klass)
        klass.attributes(
          :role,
          :value
        )

        klass.attribute :deprecated, &:deprecated?
        klass.cache_options store: Rails.cache, namespace: "alchemy-jsonapi"
      end
    end
  end
end
