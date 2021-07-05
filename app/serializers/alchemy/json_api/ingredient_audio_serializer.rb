# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientAudioSerializer
      include IngredientSerializer

      attributes(
        :autoplay,
        :controls,
        :muted,
        :loop,
      )

      attribute :value do |ingredient|
        ingredient.attachment&.url
      end

      with_options if: ->(ingredient) { ingredient.attachment } do
        attribute :audio_name do |ingredient|
          ingredient.attachment.name
        end

        attribute :audio_file_name do |ingredient|
          ingredient.attachment.file_name
        end

        attribute :audio_mime_type do |ingredient|
          ingredient.attachment.file_mime_type
        end

        attribute :audio_file_size do |ingredient|
          ingredient.attachment.file_size
        end
      end
    end
  end
end
