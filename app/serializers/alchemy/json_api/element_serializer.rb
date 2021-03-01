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

      belongs_to :parent_element, record_type: :element, serializer: self

      has_many :essences, polymorphic: true do |element|
        element.contents.map(&:essence)
      end

      has_many :nested_elements, record_type: :element, serializer: self
    end
  end
end
