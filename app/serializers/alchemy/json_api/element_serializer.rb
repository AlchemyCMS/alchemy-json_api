# frozen_string_literal: true
module Alchemy
  module JsonApi
    class ElementSerializer
      include JSONAPI::Serializer

      attributes(
        :name,
        :fixed,
        :position,
        :created_at,
        :updated_at,
      )

      attribute :deprecated do |element|
        !!element.definition[:deprecated]
      end

      has_many :essences, polymorphic: true do |element|
        element.contents.map(&:essence)
      end

      has_many :ingredients,
        serializer: ->(record) do
          "Alchemy::JsonApi::Ingredient#{record.type.demodulize}Serializer".constantize
        end

      has_many :nested_elements, record_type: :element, serializer: self
    end
  end
end
