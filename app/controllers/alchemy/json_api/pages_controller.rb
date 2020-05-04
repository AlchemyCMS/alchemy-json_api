module Alchemy
  module JsonApi
    class PagesController < ApplicationController
      include JSONAPI::Fetching
      def show
        @page = ::Alchemy::Page.preload(all_elements: {contents: :essence}).find(params[:id])
        render jsonapi: @page
      end

      private

      def jsonapi_serializer_class(resource, is_collection)
        klass = resource.class.name.demodulize
        "Alchemy::JsonApi::#{klass}Serializer".constantize
      end
    end
  end
end
