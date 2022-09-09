# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientHeadlineSerializer < BaseSerializer
      include IngredientSerializer

      attributes :level, :size
    end
  end
end
