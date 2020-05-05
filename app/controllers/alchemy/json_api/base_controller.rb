module Alchemy
  module JsonApi
    class BaseController < ::ApplicationController
      include JSONAPI::Fetching
      include JSONAPI::Errors

      private

      def jsonapi_serializer_class(resource, is_collection)
        klass = resource.class.name.demodulize
        "Alchemy::JsonApi::#{klass}Serializer".constantize
      end
    end
  end
end
