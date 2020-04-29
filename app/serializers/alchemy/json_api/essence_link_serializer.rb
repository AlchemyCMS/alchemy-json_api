require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceLinkSerializer
    include EssenceSerializer
    attributes(
      :link_title,
      :link_target
    )
  end
end
