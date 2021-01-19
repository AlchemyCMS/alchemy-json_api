# frozen_string_literal: true
module Alchemy
  module JsonApi
    module EssenceSerializer
      def self.included(klass)
        klass.include JSONAPI::Serializer
        klass.has_one :element, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer do |essence|
          essence.content.element
        end
        klass.attributes :ingredient
        klass.attribute :role do |essence|
          essence.content.name
        end
        klass.attribute :deprecated do |essence|
          !!essence.content.definition[:deprecated]
        end
      end
    end
  end
end
