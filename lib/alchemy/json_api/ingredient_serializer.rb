# frozen_string_literal: true

module Alchemy
  module JsonApi
    module IngredientSerializer
      def self.included(klass)
        klass.has_one :element, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer

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
