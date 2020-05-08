module Alchemy
  module JsonApi
    class LayoutPagesController < JsonApi::PagesController
      private

      def page_scope
        base_page_scope.layoutpages
      end
    end
  end
end
