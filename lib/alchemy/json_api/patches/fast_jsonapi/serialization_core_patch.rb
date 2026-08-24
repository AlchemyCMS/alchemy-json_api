# frozen_string_literal: true

require "jsonapi/serializer"

module Alchemy
  module JsonApi
    module Patches
      module FastJsonapi
        # Makes jsonapi-serializer's `lazy_load_data` honour *nested* includes.
        #
        # Upstream (jsonapi-serializer 2.2.0) a relationship emits its linkage as
        #
        #   output_hash[key][:data] = ... unless lazy_load_data && !included
        #
        # where `included = includes_list.include?(key)`. Two things make that
        # wrong for any sideloaded (nested) resource:
        #
        #   1. the top-level includes are a flat list of *dotted* symbols
        #      (`primary_taxon.ancestors`), so `include?(:primary_taxon)` is
        #      already false; and
        #   2. `get_included_records` hands every sideloaded record the *parent's*
        #      includes_list instead of the scoped remainder, so a nested resource
        #      evaluates its own relationships against the wrong scope.
        #
        # The upshot: enabling `lazy_load_data` suppresses linkage for *every*
        # relationship of a nested resource -- even the ones that were requested.
        #
        # This patch matches `included` against the base key of each requested
        # include path and threads the scoped remainder into each sideloaded
        # record, so `lazy_load_data: true` emits linkage only for relationships
        # actually requested at that resource's position in the include tree.
        #
        # It has no effect on relationships that do not set `lazy_load_data`
        # (their linkage is emitted regardless). Prepended onto the shared
        # SerializationCore, so it applies to every serializer.
        module SerializationCorePatch
          def relationships_hash(record, relationships = nil, fieldset = nil, includes_list = nil, params = {})
            base_keys = __alchemy_json_api_base_include_keys(includes_list)

            relationships = relationships_to_serialize if relationships.nil?
            relationships = relationships.slice(*fieldset) if fieldset.present?
            relationships = {} if fieldset == []

            relationships.each_with_object({}) do |(key, relationship), hash|
              relationship.serialize(record, base_keys.include?(key), params, hash)
            end
          end

          def get_included_records(record, includes_list, known_included_objects, fieldsets, params = {})
            return unless includes_list.present?
            return [] unless relationships_to_serialize

            parse_includes_list(includes_list).each_with_object([]) do |include_item, included_records|
              relationship_item = relationships_to_serialize[include_item.first]

              next unless relationship_item&.include_relationship?(record, params)

              included_objects = Array(relationship_item.fetch_associated_object(record, params))
              next if included_objects.empty?

              static_serializer = relationship_item.static_serializer
              static_record_type = relationship_item.static_record_type

              included_objects.each do |inc_obj|
                serializer = static_serializer || relationship_item.serializer_for(inc_obj, params)
                record_type = static_record_type || serializer.record_type

                if include_item.last.any?
                  serializer_records = serializer.get_included_records(inc_obj, include_item.last, known_included_objects, fieldsets, params)
                  included_records.concat(serializer_records) unless serializer_records.empty?
                end

                code = "#{record_type}_#{serializer.id_from_record(inc_obj, params)}"
                next if known_included_objects.include?(code)

                known_included_objects << code

                # Scope the nested record to its own include remainder rather than
                # the parent's includes_list, so its relationships are judged
                # against the correct scope.
                included_records << serializer.record_hash(inc_obj, fieldsets[record_type], include_item.last, params)
              end
            end
          end

          private

          # Reduce an includes_list -- a flat list of dotted paths at the top
          # level, or a Set/Hash of remainders when nested -- to the set of base
          # relationship keys requested at this level.
          def __alchemy_json_api_base_include_keys(includes_list)
            return Set.new if includes_list.blank?

            keys =
              if includes_list.is_a?(Hash)
                includes_list.keys
              else
                includes_list.map { |item| item.to_s.split(".", 2).first }
              end

            keys.map { |key| key.to_s.to_sym }.to_set
          end

          ::FastJsonapi::SerializationCore::ClassMethods.prepend(self)
        end
      end
    end
  end
end
