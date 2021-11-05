# frozen_string_literal: true

require "alchemy/json_api/ingredient_serializer"

module Alchemy
  module JsonApi
    class IngredientPictureSerializer
      include IngredientSerializer

      attributes(
        :title,
        :caption,
        :link_class_name,
        :link_title,
        :link_target,
      )

      attribute :value do |ingredient|
        ingredient.picture&.url
      end

      attribute :alt_text, &:alt_tag
      attribute :link_url, &:link

      with_options if: proc { |ingredient| ingredient.picture.present? } do
        attribute :image_dimensions do |ingredient|
          sizes = ingredient.settings[:size]&.split("x", 2)&.map(&:to_i) || [
            ingredient.image_file_width,
            ingredient.image_file_height,
          ]

          ratio = ingredient.image_file_width.to_f / ingredient.image_file_height
          width = sizes[0].zero? ? sizes[1] * ratio : sizes[0]
          height = sizes[1].zero? ? sizes[0] / ratio : sizes[1]

          {
            width: width,
            height: height,
          }
        end

        attribute :srcset do |ingredient|
          ingredient.settings.fetch(:srcset, []).map do |src|
            case src
            when Hash
              url = ingredient.picture_url(src)
              size = src[:size]
            else
              url = ingredient.picture_url(size: src)
              size = src
            end
            width, height = size.split("x", 2)

            {
              url: url,
              desc: "#{width}w",
              width: width,
              height: height,
            }
          end
        end

        attribute :image_name do |ingredient|
          ingredient.picture.name
        end

        attribute :image_file_name do |ingredient|
          ingredient.picture.image_file_name
        end

        attribute :image_mime_type do |ingredient|
          "image/#{ingredient.picture.image_file_format}"
        end

        attribute :image_file_size do |ingredient|
          ingredient.picture.image_file_size
        end
      end
    end
  end
end
