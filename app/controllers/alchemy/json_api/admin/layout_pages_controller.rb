# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class LayoutPagesController < JsonApi::Admin::PagesController
        private

        def page_scope
          page_scope_with_includes.layoutpages
        end
      end
    end
  end
end
