require "alchemy/json_api/essence_serializer"
require "alchemy/json_api/link_helper"

module Alchemy::JsonApi
  class EssenceFileSerializer
    include EssenceSerializer
    extend LinkHelper

    attributes(
      :title,
      :css_class
    )

    link :url do |essence|
      alchemy_link :show_attachment, essence.attachment
    end

    link :download_url do |essence|
      alchemy_link :download_attachment, essence.attachment
    end

    with_options if: Proc.new { |essence| essence.attachment.present? } do
      attribute :name do |essence|
        essence.attachment.name
      end

      attribute :file_name do |essence|
        essence.attachment.file_name
      end

      attribute :mime_type do |essence|
        essence.attachment.file_mime_type
      end

      attribute :size do |essence|
        essence.attachment.file_size
      end

      attribute :tag_list do |essence|
        essence.attachment.tag_list
      end
    end
  end
end
