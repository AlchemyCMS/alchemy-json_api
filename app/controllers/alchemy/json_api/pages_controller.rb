# frozen_string_literal: true

module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      before_action :load_page, only: :show

      def index
        allowed = [:page_layout]

        jsonapi_filter(page_scope, allowed) do |filtered|
          # decorate with our page model that has a eager loaded elements collection
          pages = filtered.result.map { |page| api_page(page) }
          jsonapi_paginate(pages) do |paginated|
            render jsonapi: paginated
          end
        end
      end

      def show
        render jsonapi: api_page(@page)
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

      def page_scope_with_includes
        base_page_scope.
          where(language: Language.current).
          includes(
            [
              :legacy_urls,
              { language: { nodes: [:parent, :children, { page: { language: { site: :languages } } }] } },
              {
                page_version_type => {
                  elements: [
                    :nested_elements,
                    { contents: { essence: :ingredient_association } },
                    { ingredients: :related_object },
                  ],
                },
              },
            ]
          )
      end

      def page_version_type
        :public_version
      end

      def api_page(page)
        Alchemy::JsonApi::Page.new(page, page_version_type: page_version_type)
      end

      def base_page_scope
        # cancancan is not able to merge our complex AR scopes for logged in users
        if can?(:edit_content, ::Alchemy::Page)
          Alchemy::Page.all.joins(page_version_type)
        else
          Alchemy::Page.published.joins(page_version_type)
        end
      end

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end
    end
  end
end
