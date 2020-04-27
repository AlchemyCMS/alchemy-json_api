require "alchemy/json_api/essence_serializer"
require "alchemy/json_api/link_helper"

module Alchemy::JsonApi
  class EssencePictureSerializer
    include EssenceSerializer
    extend LinkHelper

    attributes(
      :title,
      :caption,
      :alt_tag,
      :css_class,
      :link_title,
      :link_class_name,
      :link_target
    )

    link :url  do |essence|
      essence.picture_url
    end

    link :href do |essence|
      essence.link
    end

    with_options if: Proc.new { |essence| essence.picture.present? } do
      attribute :name do |essence|
        essence.picture.name
      end

      attribute :file_name do |essence|
        essence.picture.image_file_name
      end

      attribute :mime_type do |essence|
        "image/#{essence.picture.image_file_format}"
      end

      attribute :size do |essence|
        essence.picture.image_file_size
      end

      attribute :dimensions do |essence|
        essence.picture.image_size
      end

      attribute :tag_list do |essence|
        essence.picture.tag_list
      end
    end
  end
end
