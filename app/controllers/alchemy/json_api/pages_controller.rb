# frozen_string_literal: true

module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      before_action :load_page_for_cache_key, only: :show

      def index
        allowed = [:page_layout, :urlname]

        jsonapi_filter(page_scope, allowed) do |filtered_pages|
          @pages = filtered_pages.result
          if stale?(last_modified: @pages.maximum(:published_at), etag: @pages.max_by(&:cache_key).cache_key)
            # Only load pages with all includes when browser cache is stale
            jsonapi_filter(page_scope_with_includes, allowed) do |filtered|
              # decorate with our page model that has a eager loaded elements collection
              filtered_pages = filtered.result.map { |page| api_page(page) }
              jsonapi_paginate(filtered_pages) do |paginated|
                render jsonapi: paginated
              end
            end
          end
        end
      end

      def show
        if stale?(last_modified: last_modified_for(@page), etag: @page.cache_key)
          # Only load page with all includes when browser cache is stale
          render jsonapi: api_page(load_page)
        end
      end

      private

      # Get page w/o includes to get cache key
      def load_page_for_cache_key
        @page = page_scope.where(id: params[:path]).
          or(page_scope.where(urlname: params[:path])).first!
      end

      def last_modified_for(page)
        page.published_at
      end

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
        page_scope_with_includes.find_by(id: params[:path])
      end

      def load_page_by_urlname
        page_scope_with_includes.find_by(urlname: params[:path])
      end

      def page_scope
        base_page_scope.contentpages
      end

      def page_scope_with_includes
        page_scope.
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
          Alchemy::Language.current.pages.joins(page_version_type)
        else
          Alchemy::Language.current.pages.published.joins(page_version_type)
        end
      end

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end
    end
  end
end
