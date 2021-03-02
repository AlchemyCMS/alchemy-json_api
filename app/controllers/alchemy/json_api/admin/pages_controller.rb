# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class PagesController < JsonApi::PagesController
        authorize_resource

        def show
          render jsonapi: Alchemy::JsonApi::Page.new(@page, page_version: :draft_version)
        end

        private

        def load_page
          @page = page_scope.find(params[:id])
        end

        def base_page_scope
          ::Alchemy::Page.all
        end

        def page_scope_with_includes
          base_page_scope.
            where(language: Language.current).
            preload(
              language: { nodes: [:parent, :page, :children] },
              draft_version: { elements: { contents: { essence: :ingredient_association } } },
            )
        end
      end
    end
  end
end
