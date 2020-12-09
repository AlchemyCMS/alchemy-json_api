# frozen_string_literal: true
module Alchemy
  module JsonApi
    class LayoutPagesController < JsonApi::PagesController
      private

      def page_scope
        page_scope_with_includes.layoutpages
      end
    end
  end
end
