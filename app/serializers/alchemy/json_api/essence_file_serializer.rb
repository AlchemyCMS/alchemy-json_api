require 'alchemy/json_api/essence_serializer'

module Alchemy::JsonApi
  class EssenceFileSerializer
    include EssenceSerializer
    attributes(
      :title,
      :css_class
    )

    link :url do |essence|
      if Rails.application.routes.default_url_options[:host]
        Alchemy::Engine.routes.url_helpers.show_attachment_url(essence.attachment)
      else
        Alchemy::Engine.routes.url_helpers.show_attachment_path(essence.attachment)
      end
    end

    link :download_url do |essence|
      if Rails.application.routes.default_url_options[:host]
        Alchemy::Engine.routes.url_helpers.download_attachment_url(essence.attachment)
      else
        Alchemy::Engine.routes.url_helpers.download_attachment_path(essence.attachment)
      end
    end

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
