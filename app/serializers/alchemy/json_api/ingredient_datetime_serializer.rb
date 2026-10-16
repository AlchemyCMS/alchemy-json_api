# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientDatetimeSerializer < BaseSerializer
      include IngredientSerializer

      typelize(value: "string | null")
    end
  end
end
