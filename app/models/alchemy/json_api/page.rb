module Alchemy
  module JsonApi
    class Page < SimpleDelegator
      def initialize(page, page_version: :public_version)
        @page_version = page.public_send(page_version)
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

      private

      def element_repository
        return Alchemy::ElementsRepository.none unless @page_version

        Alchemy::ElementsRepository.new(@page_version.elements.published)
      end
    end
  end
end
