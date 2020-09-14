# frozen_string_literal: true
module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      before_action :load_page, only: :show

      def index
        allowed = [:page_layout]

        jsonapi_filter(page_scope, allowed) do |filtered|
          jsonapi_paginate(filtered.result) do |paginated|
            render jsonapi: paginated
          end
        end
      end

      def show
        render jsonapi: @page
      end

      private

      def jsonapi_meta(pages)
        pagination = jsonapi_pagination_meta(pages)

        {
          pagination: pagination.presence,
          total: page_scope.count
        }.compact
      end

      def load_page
        @page = load_page_by_id || load_page_by_urlname || raise(ActiveRecord::RecordNotFound)
      end

      def load_page_by_id
        page_scope.find_by(id: params[:id])
      end

      def load_page_by_urlname
        # The route param is called :id although it might be a string
        page_scope.find_by(urlname: params[:id])
      end

      def page_scope
        base_page_scope.contentpages
      end

      def base_page_scope
        ::Alchemy::Page.
          with_language(Language.current).
          published.
          preload(language: {nodes: [:parent, :page]}, all_elements: [:parent_element, :nested_elements, { contents: { essence: :ingredient_association } }])
      end

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end
    end
  end
end
