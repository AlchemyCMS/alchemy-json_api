require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceHtmlSerializer
    include EssenceSerializer
    attributes :source
  end
end
