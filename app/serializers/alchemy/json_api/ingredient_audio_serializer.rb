# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientAudioSerializer < BaseSerializer
      include IngredientSerializer

      attributes(
        :autoplay,
        :controls,
        :muted,
        :loop
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

      typelize(
        value: "string | null",
        autoplay: "boolean | null",
        controls: "boolean | null",
        muted: "boolean | null",
        loop: "boolean | null",
        audio_name: "string",
        audio_file_name: "string",
        audio_mime_type: "string",
        audio_file_size: "number"
      )
    end
  end
end
