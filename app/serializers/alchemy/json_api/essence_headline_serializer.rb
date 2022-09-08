# frozen_string_literal: true

require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceHeadlineSerializer < BaseSerializer
      include EssenceSerializer

      attributes :level, :size
    end
  end
end
