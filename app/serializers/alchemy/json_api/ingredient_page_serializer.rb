# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientPageSerializer < BaseSerializer
      include IngredientSerializer

      attribute :value do |ingredient|
        ingredient.page&.url_path
      end

      attribute :page_name do |ingredient|
        ingredient.page&.name
      end

      attribute :page_url do |ingredient|
        ingredient.page&.url_path
      end

      has_one :page, record_type: :page, serializer: PageSerializer do |ingredient|
        Alchemy::JsonApi::Page.new(ingredient.page) if ingredient.page
      end
    end
  end
end
