# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientRichtextSerializer < BaseSerializer
      include IngredientSerializer

      attributes(
        :sanitized_body,
        :stripped_body
      )

      attribute :body, &:value
    end
  end
end
