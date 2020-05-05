module Alchemy
  module JsonApi
    class PagesController < BaseController
      include JSONAPI::Fetching

      before_action :load_page

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
        page_scope.find_by(
          urlname: params[:id],
          language_code: params[:locale] || Language.current.code
        )
      end

      def page_scope
        ::Alchemy::Page.
          preload(all_elements: [:parent_element, :nested_elements, {contents: {essence: :ingredient_association}}])
      end
    end
  end
end
