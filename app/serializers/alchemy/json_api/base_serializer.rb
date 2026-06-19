module Alchemy
  module JsonApi
    class BaseSerializer
      include JSONAPI::Serializer

      set_key_transform Alchemy::JsonApi.key_transform

      # This method can be overwritten in individual serializers to fetch objects that belong to the related object in some form.
      # This takes an Array of relation names that can be passed to the Rails preloader.
      def self.preload_relations
        []
      end
    end
  end
end
