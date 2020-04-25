require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceBooleanSerializer
    include EssenceSerializer
    attributes :value
  end
end
