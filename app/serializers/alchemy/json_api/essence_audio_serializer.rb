# frozen_string_literal: true

require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceAudioSerializer
      include EssenceSerializer

      attributes(
        :autoplay,
        :controls,
        :muted,
        :loop,
      )

      attribute :ingredient do |essence|
        essence.attachment&.url
      end

      with_options if: ->(essence) { essence.attachment } do
        attribute :audio_name do |essence|
          essence.attachment.name
        end

        attribute :audio_file_name do |essence|
          essence.attachment.file_name
        end

        attribute :audio_mime_type do |essence|
          essence.attachment.file_mime_type
        end

        attribute :audio_file_size do |essence|
          essence.attachment.file_size
        end
      end
    end
  end
end
