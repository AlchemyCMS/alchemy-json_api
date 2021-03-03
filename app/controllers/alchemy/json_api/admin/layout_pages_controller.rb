# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class LayoutPagesController < PagesController
        private

        def page_scope
          page_scope_with_includes(page_version: :draft_version).layoutpages
        end
      end
    end
  end
end
