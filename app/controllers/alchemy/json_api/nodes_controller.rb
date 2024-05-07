# frozen_string_literal: true

module Alchemy
  module JsonApi
    class NodesController < JsonApi::BaseController
      def index
        @nodes = node_scope.select(:id, :updated_at)
        if stale?(last_modified: @nodes.maximum(:updated_at), etag: @nodes)
          jsonapi_paginate(node_scope_with_includes) do |paginated|
            render jsonapi: paginated
          end
        end

        expires_in cache_duration, {public: true, must_revalidate: true}
      end

      private

      def cache_duration
        ENV.fetch("ALCHEMY_JSON_API_CACHE_DURATION", 3).to_i.hours
      end

      def jsonapi_meta(nodes)
        pagination = jsonapi_pagination_meta(nodes)

        {
          pagination: pagination.presence,
          total: node_scope.count
        }.compact
      end

      def node_scope
        Alchemy::Node.all
      end

      def node_scope_with_includes
        if params[:include].present?
          includes = params[:include].split(",").map do |association|
            association.split(".").reverse.inject({}) do |value, key|
              {key.to_sym => value}
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
