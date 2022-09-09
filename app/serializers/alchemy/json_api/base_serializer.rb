module Alchemy
  module JsonApi
    class BaseSerializer
      include JSONAPI::Serializer

      set_key_transform Alchemy::JsonApi.key_transform
    end
  end
end
