require 'alchemy/json_api/essence_serializer'

module Alchemy::JsonApi
  class EssenceTextSerializer
    include EssenceSerializer
    attributes(
      :body
    )

    link :href, :link

    has_one :content
  end
end
