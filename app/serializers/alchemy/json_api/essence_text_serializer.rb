# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceTextSerializer
      include EssenceSerializer
      attributes(
        :body,
        :link_title,
        :link_target,
      )
      attribute :link_url, &:link
    end
  end
end
