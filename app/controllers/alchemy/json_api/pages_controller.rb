# frozen_string_literal: true

module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      before_action :load_page, only: :show

      def index
        allowed = [:page_layout]

        jsonapi_filter(page_scope, allowed) do |filtered|
          # decorate with our page model that has a eager loaded elements collection
          pages = filtered.result.map { |p| Alchemy::JsonApi::Page.new(p) }
          jsonapi_paginate(pages) do |paginated|
            render jsonapi: paginated
          end
        end
      end

      def show
        render jsonapi: Alchemy::JsonApi::Page.new(@page)
      end

      private

      def jsonapi_meta(pages)
        pagination = jsonapi_pagination_meta(pages)

        {
          pagination: pagination.presence,
          total: page_scope.count,
        }.compact
      end

      def load_page
        @page = load_page_by_id || load_page_by_urlname || raise(ActiveRecord::RecordNotFound)
      end

      def load_page_by_id
        return unless params[:path] =~ /\A\d+\z/
        page_scope.find_by(id: params[:path])
      end

      def load_page_by_urlname
        page_scope.find_by(urlname: params[:path])
      end

      def page_scope
        page_scope_with_includes.contentpages
      end

      def page_scope_with_includes(page_version: :public_version)
        base_page_scope.
          where(language: Language.current).
          includes(
            [
              :legacy_urls,
              { language: { nodes: [:parent, :children, { page: { language: { site: :languages } } }] } },
              {
                page_version => {
                  elements: [
                    :nested_elements,
                    { contents: { essence: :ingredient_association } },
                  ],
                },
              },
            ]
          )
      end

      def base_page_scope
        # cancancan is not able to merge our complex AR scopes for logged in users
        if can?(:edit_content, ::Alchemy::Page)
          Alchemy::Page.all
        else
          Alchemy::Page.published
        end
      end

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end
    end
  end
end
