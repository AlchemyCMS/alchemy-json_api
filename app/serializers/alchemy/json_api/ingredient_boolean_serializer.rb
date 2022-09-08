# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientBooleanSerializer < BaseSerializer
      include IngredientSerializer
    end
  end
end
