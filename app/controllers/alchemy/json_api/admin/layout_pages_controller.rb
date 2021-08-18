# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class LayoutPagesController < JsonApi::Admin::PagesController
        private

        def page_scope
          base_page_scope.layoutpages
        end
      end
    end
  end
end
