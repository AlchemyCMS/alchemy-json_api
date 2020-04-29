require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceTextSerializer
    include EssenceSerializer
    attributes(
      :body,
      :link_title,
      :link_target
    )
    attribute :link_url, &:link
  end
end
