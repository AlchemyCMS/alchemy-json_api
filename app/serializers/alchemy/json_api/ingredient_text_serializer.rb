# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientTextSerializer < BaseSerializer
      include IngredientSerializer

      attributes(
        :link,
        :link_class_name,
        :link_target,
        :link_title
      )

      # maintain compatibility with EssenceText
      attribute :body, &:value
      attribute :link_url, &:link

      # Introduced in Alchemy 6.1
      if Alchemy::Ingredients::Text.stored_attributes[:data].include?(:dom_id)
        attribute :dom_id
      end
    end
  end
end
