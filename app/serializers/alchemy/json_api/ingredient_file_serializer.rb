# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientFileSerializer < BaseSerializer
      include IngredientSerializer

      attribute :link_title, &:title

      attribute :value do |ingredient|
        ingredient.attachment&.url
      end

      with_options if: proc { |ingredient| ingredient.attachment } do
        attribute :attachment_name do |ingredient|
          ingredient.attachment.name
        end

        attribute :attachment_file_name do |ingredient|
          ingredient.attachment.file_name
        end

        attribute :attachment_mime_type do |ingredient|
          ingredient.attachment.file_mime_type
        end

        attribute :attachment_file_size do |ingredient|
          ingredient.attachment.file_size
        end
      end
    end
  end
end
