# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientNodeSerializer < BaseSerializer
      include IngredientSerializer

      attribute :value do |ingredient|
        ingredient.node&.name
      end

      belongs_to :node, record_type: :node, serializer: ::Alchemy::JsonApi::NodeSerializer

      with_options if: proc { |ingredient| ingredient.node } do
        attribute :name do |ingredient|
          ingredient.node.name
        end

        attribute :link_url do |ingredient|
          ingredient.node.url
        end

        attribute :link_title do |ingredient|
          ingredient.node.title
        end

        attribute :link_nofollow do |ingredient|
          ingredient.node.nofollow
        end
      end
    end
  end
end
