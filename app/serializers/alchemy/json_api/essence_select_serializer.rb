require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceSelectSerializer
    include EssenceSerializer
    attributes :value
  end
end
