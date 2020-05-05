require "alchemy/json_api/essence_serializer"
require "alchemy/json_api/link_helper"

module Alchemy::JsonApi
  class EssencePictureSerializer
    include EssenceSerializer

    attributes(
      :title,
      :caption,
      :link_title,
      :link_target
    )
    attribute :ingredient, &:picture_url
    attribute :alt_text, &:alt_tag
    attribute :link_url, &:link

    with_options if: Proc.new { |essence| essence.picture.present? } do
      attribute :image_dimensions do |essence|
        essence.sizes_from_string(essence.render_size)
      end

      attribute :image_name do |essence|
        essence.picture.name
      end

      attribute :image_file_name do |essence|
        essence.picture.image_file_name
      end

      attribute :image_mime_type do |essence|
        "image/#{essence.picture.image_file_format}"
      end

      attribute :image_file_size do |essence|
        essence.picture.image_file_size
      end
    end
  end
end
