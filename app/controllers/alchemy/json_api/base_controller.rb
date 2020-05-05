module Alchemy
  module JsonApi
    class BaseController < ::ApplicationController
      private

      def jsonapi_serializer_class(resource, is_collection)
        klass = resource.class.name.demodulize
        "Alchemy::JsonApi::#{klass}Serializer".constantize
      end
    end
  end
end
