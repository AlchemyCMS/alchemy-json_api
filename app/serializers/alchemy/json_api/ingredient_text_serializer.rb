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
        :link_title,
      )

      # maintain compatibility with EssenceText
      attribute :body, &:value
      attribute :link_url, &:link
    end
  end
end
