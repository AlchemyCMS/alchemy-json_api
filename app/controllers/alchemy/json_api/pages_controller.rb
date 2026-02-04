# frozen_string_literal: true

module Alchemy
  module JsonApi
    class PagesController < JsonApi::BaseController
      CACHE_DURATION = 600
      JSONAPI_STALEMAKERS = %i[include fields sort filter page]

      before_action :load_page_for_cache_key, only: :show

      def index
        allowed = Alchemy::Page.ransackable_attributes

        jsonapi_filter(page_scope, allowed) do |filtered_pages|
          @pages = filtered_pages.result

          if !@pages.all?(&:cache_page?)
            render_pages_json(allowed) && return
          elsif stale?(etag: etag(@pages))
            render_pages_json(allowed)
          end
        end

        expires_in cache_duration, {public: @pages.none?(&:restricted?)}.merge(caching_options)
      end

      def show
        if !@page.cache_page?
          render(jsonapi: api_page(load_page)) && return
        end

        if stale?(etag: etag(@page))
          # Only load page with all includes when browser cache is stale
          render jsonapi: api_page(load_page)
        end

        expires_in cache_duration, {public: !@page.restricted?}.merge(caching_options)
      end

      private

      def render_pages_json(allowed)
        # Only load pages with all includes when browser cache is stale
        jsonapi_filter(page_scope_with_includes, allowed) do |filtered|
          jsonapi_paginate(filtered.result) do |paginated|
            # decorate with our page model that has a eager loaded elements collection
            decorated_pages = preload_ingredients(paginated).map { |page| api_page(page) }
            render jsonapi: decorated_pages
          end
        end
      end

      def cache_duration
        Alchemy::JsonApi.page_cache_max_age
      end

      def caching_options
        Alchemy::JsonApi.page_caching_options
      end

      # Get page w/o includes to get cache key
      def load_page_for_cache_key
        @page = page_scope.where(id: params[:path])
          .or(page_scope.where(urlname: params[:path])).first!
      end

      def jsonapi_meta(pages)
        pagination = jsonapi_pagination_meta(pages)

        {
          pagination: pagination.presence,
          total: page_scope.count
        }.compact
      end

      def load_page
        @page = preload_ingredients(
          [load_page_by_id || load_page_by_urlname || raise(ActiveRecord::RecordNotFound)]
        ).first
      end

      def load_page_by_id
        return unless /\A\d+\z/.match?(params[:path])

        page_scope_with_includes.find_by(id: params[:path])
      end

      def load_page_by_urlname
        page_scope_with_includes.find_by(urlname: params[:path])
      end

      def page_scope
        base_page_scope.contentpages
      end

      def page_scope_with_includes
        page_scope
          .includes(
            [
              :legacy_urls,
              {language: {nodes: [:parent, :children, {page: {language: {site: :languages}}}]}},
              {
                page_version_type => {
                  elements: [
                    :nested_elements,
                    {ingredients: :related_object}
                  ]
                }
              }
            ]
          )
      end

      def preload_ingredients(scope)
        if params[:include]&.match?(/ingredients/)
          Alchemy::JsonApi::Page.preload_ingredient_relations(scope, page_version_type)
        else
          scope
        end
      end

      def page_version_type
        :public_version
      end

      def api_page(page)
        Alchemy::JsonApi::Page.new(page, page_version_type: page_version_type)
      end

      def etag(pages)
        pages = Array.wrap(pages)
        return unless pages.any?
        relevant_params = params.to_unsafe_hash.slice(*JSONAPI_STALEMAKERS).flatten.compact
        pages.map { |page| page_cache_key(page) }.concat(relevant_params)
      end

      def page_cache_key(page)
        page.cache_key_with_version
      end

      def base_page_scope
        # cancancan is not able to merge our complex AR scopes for logged in users
        if can?(:edit_content, ::Alchemy::Page)
          current_language.pages.joins(page_version_type)
        else
          current_language.pages.published.joins(page_version_type)
        end
      end

      def current_language
        Alchemy::Current.language
      end

      def jsonapi_serializer_class(_resource, _is_collection)
        ::Alchemy::JsonApi::PageSerializer
      end

      # These overrides have to be in place until
      # https://github.com/stas/jsonapi.rb/pull/91
      # is merged and released
      def jsonapi_paginate(resources)
        @_jsonapi_original_size = resources.size
        super
      end

      def jsonapi_pagination_meta(resources)
        return {} unless JSONAPI::Rails.is_collection?(resources)

        _, limit, page = jsonapi_pagination_params

        numbers = { current: page }

        total = @_jsonapi_original_size

        last_page = [1, (total.to_f / limit).ceil].max

        if page > 1
          numbers[:first] = 1
          numbers[:prev] = page - 1
        end

        if page < last_page
          numbers[:next] = page + 1
          numbers[:last] = last_page
        end

        if total.present?
          numbers[:records] = total
        end

        numbers
      end
    end
  end
end
