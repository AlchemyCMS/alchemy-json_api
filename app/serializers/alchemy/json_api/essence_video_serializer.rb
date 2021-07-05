# frozen_string_literal: true

require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceVideoSerializer
      include EssenceSerializer

      attributes(
        :width,
        :height,
        :allow_fullscreen,
        :autoplay,
        :controls,
        :preload,
      )

      attribute :ingredient do |essence|
        essence.attachment&.url
      end

      with_options if: ->(essence) { essence.attachment } do
        attribute :video_name do |essence|
          essence.attachment.name
        end

        attribute :video_file_name do |essence|
          essence.attachment.file_name
        end

        attribute :video_mime_type do |essence|
          essence.attachment.file_mime_type
        end

        attribute :video_file_size do |essence|
          essence.attachment.file_size
        end
      end
    end
  end
end
