# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssencePageSerializer
      include EssenceSerializer

      attribute :ingredient do |essence|
        essence.page&.url_path
      end

      attribute :page_name do |essence|
        essence.page&.name
      end

      attribute :page_url do |essence|
        essence.page&.url_path
      end

      has_one :page, record_type: :page, serializer: PageSerializer
    end
  end
end
