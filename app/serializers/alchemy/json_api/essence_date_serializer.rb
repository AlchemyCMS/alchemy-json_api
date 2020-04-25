require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceDateSerializer
    include EssenceSerializer
    attributes :date
  end
end
