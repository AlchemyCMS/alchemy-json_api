# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientHeadlineSerializer < BaseSerializer
      include IngredientSerializer

      attributes :level, :size

      # Introduced in Alchemy 6.1
      if Alchemy::Ingredients::Headline.stored_attributes[:data].include?(:dom_id)
        attribute :dom_id
      end
    end
  end
end
