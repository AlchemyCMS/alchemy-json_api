# frozen_string_literal: true
module Alchemy
  module JsonApi
    class LayoutPagesController < JsonApi::PagesController
      private

      def base_page_scope
        ::Alchemy::JsonApi::Page.all
      end

      def page_scope
        page_scope_with_includes.layoutpages
      end
    end
  end
end
