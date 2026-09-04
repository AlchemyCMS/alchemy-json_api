module Alchemy
  module JsonApi
    class Page < SimpleDelegator
      def self.preload_ingredient_relations(pages, page_version_type)
        related_objects = pages.map { |page| page.send(page_version_type) }
          .flat_map(&:elements)
          .flat_map(&:ingredients)
          .filter_map(&:related_object)

        related_objects.group_by(&:class).each do |klass, objects|
          klass.alchemy_element_preloads(objects) if klass.respond_to?(:alchemy_element_preloads)
        end
        pages
      end

      attr_reader :page_version_type, :page_version

      def initialize(page, page_version_type: :public_version)
        @page_version_type = page_version_type
        @page_version = page.public_send(page_version_type)
        super(page)
      end

      # All elements including nested and fixed elements
      def all_elements
        @_all_elements ||= element_repository
      end

      # Not nested unfixed top level elements
      def elements
        @_elements ||= element_repository.not_nested.unfixed
      end

      # Not nested fixed top level elements
      def fixed_elements
        @_fixed_elements ||= element_repository.not_nested.fixed
      end

      def all_element_ids
        @_all_element_ids ||= all_elements.map(&:id)
      end

      def element_ids
        @_element_ids ||= elements.map(&:id)
      end

      def fixed_element_ids
        @_fixed_element_ids ||= fixed_elements.map(&:id)
      end

      def ancestor_ids
        @_ancestor_ids ||= ancestors.map(&:id)
      end

      private

      def element_repository
        return Alchemy::ElementsRepository.none unless page_version

        page_version.element_repository.visible
      end
    end
  end
end
