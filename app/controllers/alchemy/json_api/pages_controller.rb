module Alchemy
  module JsonApi
    class PagesController < ApplicationController
      include JSONAPI::Fetching
      def show
        @page = ::Alchemy::Page.preload(all_elements: [:parent_element, :nested_elements, {contents: {essence: :ingredient_association}}]).find(params[:id])
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
