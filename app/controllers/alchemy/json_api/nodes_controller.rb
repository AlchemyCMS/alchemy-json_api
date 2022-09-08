# frozen_string_literal: true

module Alchemy
  module JsonApi
    class NodesController < JsonApi::BaseController
      ALLOWED_FILTERS = %i[
        page_page_layout
        page_elements_name
        page_all_elements_name
        page_fixed_elements_name
      ]

      def index
        jsonapi_filter(node_scope, ALLOWED_FILTERS) do |filtered_nodes|
          @nodes = filtered_nodes.result(distinct: true)

          puts "===========SQL============"
          puts @nodes.to_sql
          puts "===========SQL============"

          if stale?(last_modified: @nodes.maximum(:updated_at), etag: @nodes)
            jsonapi_filter(node_scope_with_includes, ALLOWED_FILTERS) do |nodes|
              jsonapi_paginate(nodes.result(distinct: true)) do |paginated|
                render jsonapi: paginated
              end
            end
          end
        end

        expires_in cache_duration, { public: true, must_revalidate: true }
      end

      private

      def cache_duration
        ENV.fetch("ALCHEMY_JSON_API_CACHE_DURATION", 3).to_i.hours
      end

      def jsonapi_meta(nodes)
        pagination = jsonapi_pagination_meta(nodes)

        {
          pagination: pagination.presence,
          total: node_scope.count,
        }.compact
      end

      def node_scope
        Alchemy::Node.all
      end

      def node_scope_with_includes
        if params[:include].present?
          includes = params[:include].split(",").map do |association|
            association.split(".").reverse.inject({}) do |value, key|
              { key.to_sym => value }
            end
          end
          node_scope.includes(includes)
        else
          node_scope
        end
      end

      def jsonapi_serializer_class(*)
        ::Alchemy::JsonApi::NodeSerializer
      end
    end
  end
end
