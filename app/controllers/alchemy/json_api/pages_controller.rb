module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      before_action :load_page, only: :show

      def index
        allowed = [:page_layout]

        jsonapi_filter(page_scope, allowed) do |filtered|
          render jsonapi: filtered.result
        end
      end

      def show
        render jsonapi: @page
      end

      private

      def load_page
        @page = load_page_by_id || load_page_by_urlname || raise(ActiveRecord::RecordNotFound)
      end

      def load_page_by_id
        page_scope.find_by(id: params[:id])
      end

      def load_page_by_urlname
        # The route param is called :id although it might be a string
        page_scope.find_by(urlname: params[:id])
      end

      def page_scope
        base_page_scope.contentpages
      end

      def base_page_scope
        ::Alchemy::Page.
          with_language(Language.current).
          published.
          preload(all_elements: [:parent_element, :nested_elements, { contents: { essence: :ingredient_association } }])
      end

      private

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end
    end
  end
end
