# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientVideoSerializer < BaseSerializer
      include IngredientSerializer

      attributes(
        :width,
        :height,
        :allow_fullscreen,
        :autoplay,
        :controls,
        :preload
      )

      attribute :value do |ingredient|
        ingredient.attachment&.url
      end

      with_options if: ->(ingredient) { ingredient.attachment } do
        attribute :video_name do |ingredient|
          ingredient.attachment.name
        end

        attribute :video_file_name do |ingredient|
          ingredient.attachment.file_name
        end

        attribute :video_mime_type do |ingredient|
          ingredient.attachment.file_mime_type
        end

        attribute :video_file_size do |ingredient|
          ingredient.attachment.file_size
        end
      end
    end
  end
end
