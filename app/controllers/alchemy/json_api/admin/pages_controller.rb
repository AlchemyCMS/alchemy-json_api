# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class PagesController < JsonApi::PagesController
        def show
          render jsonapi: Alchemy::JsonApi::Page.new(@page, page_version: :draft_version)
        end

        private

        def page_scope
          page_scope_with_includes(page_version: :draft_version).contentpages
        end
      end
    end
  end
end
