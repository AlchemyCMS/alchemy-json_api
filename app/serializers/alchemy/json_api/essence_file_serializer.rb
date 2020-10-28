# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceFileSerializer
      include EssenceSerializer

      attribute :link_title, &:title

      attribute :ingredient, &:attachment_url

      with_options if: proc { |essence| essence.attachment.present? } do
        attribute :attachment_name do |essence|
          essence.attachment.name
        end

        attribute :attachment_file_name do |essence|
          essence.attachment.file_name
        end

        attribute :attachment_mime_type do |essence|
          essence.attachment.file_mime_type
        end

        attribute :attachment_file_size do |essence|
          essence.attachment.file_size
        end
      end
    end
  end
end
