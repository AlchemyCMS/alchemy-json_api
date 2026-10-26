# frozen_string_literal: true

module Alchemy
  module JsonApi
    class LayoutPagesController < JsonApi::PagesController
      include FindLayoutPageByPageLayout

      private

      def page_scope
        base_page_scope.layoutpages
      end
    end
  end
end
