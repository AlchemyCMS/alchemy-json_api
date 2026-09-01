# frozen_string_literal: true

module Alchemy
  module JsonApi
    class ElementSerializer < BaseSerializer
      attributes(
        :name,
        :fixed,
        :position,
        :created_at,
        :updated_at
      )

      cache_options store: Rails.cache, namespace: "alchemy-jsonapi"

      attribute :deprecated do |element|
        !!element.definition.deprecated
      end

      has_many :ingredients,
        lazy_load_data: true,
        serializer: ->(record) do
          "Alchemy::JsonApi::Ingredient#{record.type.demodulize}Serializer".constantize
        end

      # Eager: the element tree (all_elements -> nested_elements) is recursive
      # and can't be expressed as an `include`, so its linkage is always present.
      has_many :nested_elements, record_type: :element, serializer: self
    end
  end
end
