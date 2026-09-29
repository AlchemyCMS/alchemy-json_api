module Alchemy
  module JsonApi
    class BaseSerializer
      include JSONAPI::Serializer

      set_key_transform Alchemy::JsonApi.key_transform

      class_attribute :typelized_attributes, default: {}

      # Declares the TypeScript types of attributes
      # used by `bin/rails alchemy:json_api:generate_types`
      #
      #   typelize(name: "string", position: "number")
      def self.typelize(**types)
        self.typelized_attributes = typelized_attributes.merge(types.stringify_keys)
      end
    end
  end
end
