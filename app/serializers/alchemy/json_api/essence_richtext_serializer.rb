# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceRichtextSerializer
      include EssenceSerializer
      attributes(
        :body,
        :sanitized_body,
        :stripped_body,
      )
    end
  end
end
