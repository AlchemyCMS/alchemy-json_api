# frozen_string_literal: true

require "jsonapi/serializer"

module Alchemy
  module JsonApi
    module Patches
      module FastJsonapi
        # Make relationship linkage lazy by default.
        #
        # By default jsonapi-serializer emits every relationship's `data`
        # linkage whether or not the relationship was requested via `include`.
        # That is surprising (a client that didn't ask for a relationship still
        # receives its linkage) and, because computing the linkage ids loads the
        # association, it causes N+1 queries on the server for relationships
        # nobody asked for.
        #
        # This defaults every relationship to `lazy_load_data: true`, so linkage
        # is emitted only for relationships that were requested. A relationship
        # can still opt back in unconditionally with `lazy_load_data: false`.
        #
        # Works together with SerializationCorePatch, which makes lazy loading
        # honour nested includes.
        module LazyLoadRelationshipsPatch
          def create_relationship(base_key, relationship_type, options, block)
            super(base_key, relationship_type, {lazy_load_data: true, **options}, block)
          end

          ::FastJsonapi::ObjectSerializer::ClassMethods.prepend(self)
        end
      end
    end
  end
end
