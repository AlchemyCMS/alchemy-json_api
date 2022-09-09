# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientLinkSerializer < BaseSerializer
      include IngredientSerializer

      attributes(
        :link_class_name,
        :link_target,
        :link_title
      )
    end
  end
end
