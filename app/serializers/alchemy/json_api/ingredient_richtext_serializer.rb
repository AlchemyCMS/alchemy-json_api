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

      typelize(
        value: "string | null",
        sanitized_body: "string | null",
        stripped_body: "string | null",
        body: "string | null"
      )
    end
  end
end
