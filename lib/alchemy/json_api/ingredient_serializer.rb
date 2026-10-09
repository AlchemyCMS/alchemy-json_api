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
        klass.cache_options store: Rails.cache, namespace: "alchemy-jsonapi"

        klass.typelize(
          role: "string",
          created_at: "string",
          updated_at: "string",
          deprecated: "boolean"
        )
      end
    end
  end
end
