# frozen_string_literal: true

require "jsonapi/serializer"

module Alchemy
  module JsonApi
    module Patches
      module FastJsonapi
        # Makes jsonapi-serializer's `lazy_load_data` honour *nested* includes.
        #
        # With `lazy_load_data: true` a relationship only emits its linkage when
        # it was requested, which upstream (jsonapi-serializer 2.2.0) decides
        # with `includes_list.include?(key)`. Two things break that for any
        # sideloaded (nested) resource:
        #
        #   1. the includes are dotted paths (`primary_taxon.ancestors`), so
        #      `include?(:primary_taxon)` never matches; and
        #   2. `get_included_records` hands each sideloaded record the *parent's*
        #      includes_list instead of the scoped remainder, so a nested
        #      resource judges its own relationships against the wrong paths.
        #
        # Together these suppress linkage for *every* relationship of a nested
        # resource -- even requested ones -- making lazy_load_data unusable
        # beyond top-level relationships.
        #
        # The two overrides below fix each half: `relationships_hash` matches the
        # base key of every requested path, and `get_included_records` threads
        # the scoped remainder into each sideloaded record. Relationships that do
        # not set `lazy_load_data` are unaffected (their linkage always emits).
        # Prepended onto the shared SerializationCore, so every serializer gets it.
        module SerializationCorePatch
          # Upstream tests `includes_list.include?(key)` verbatim. Normalising the
          # list to the set of base keys first makes that check match dotted paths,
          # so the rest of upstream's implementation can stand.
          def relationships_hash(record, relationships = nil, fieldset = nil, includes_list = nil, params = {})
            super(record, relationships, fieldset, base_include_keys(includes_list), params)
          end

          # Verbatim copy of FastJsonapi::SerializationCore 2.2.0 with a single
          # change, flagged inline below -- keep it diffable against upstream.
          def get_included_records(record, includes_list, known_included_objects, fieldsets, params = {})
            return unless includes_list.present?
            return [] unless relationships_to_serialize

            includes_list = parse_includes_list(includes_list)

            includes_list.each_with_object([]) do |include_item, included_records|
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

                # CHANGED vs upstream: pass this include's remainder rather than
                # the parent's parsed includes_list, so the sideloaded record
                # scopes its own relationships correctly.
                included_records << serializer.record_hash(inc_obj, fieldsets[record_type], include_item.last, params)
              end
            end
          end

          private

          # The base relationship keys requested at this level, e.g.
          # `[:primary_taxon.ancestors, :author]` -> Set[:primary_taxon, :author].
          def base_include_keys(includes_list)
            return Set.new if includes_list.blank?

            includes_list.map { |path| path.to_s.split(".", 2).first.to_sym }.to_set
          end

          ::FastJsonapi::SerializationCore::ClassMethods.prepend(self)
        end
      end
    end
  end
end
