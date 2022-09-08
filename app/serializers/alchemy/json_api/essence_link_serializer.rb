# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceLinkSerializer < BaseSerializer
      include EssenceSerializer
      attributes(
        :link_title,
        :link_target,
      )
    end
  end
end
