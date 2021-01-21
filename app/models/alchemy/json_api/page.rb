module Alchemy
  module JsonApi
    class Page < BaseRecord
      self.table_name = "alchemy_pages"

      belongs_to :language, class_name: "Alchemy::Language"

      has_many :all_elements,
        -> { available.order(:position) },
        class_name: "Alchemy::JsonApi::Element",
        inverse_of: :page

      scope :published, -> {
          where("#{table_name}.public_on <= :time AND " \
                "(#{table_name}.public_until IS NULL " \
                "OR #{table_name}.public_until >= :time)", time: Time.current)
        }

      scope :contentpages, -> { where(layoutpage: false) }
      scope :layoutpages, -> { where(layoutpage: true) }
      scope :with_language, ->(language_id) { where(language_id: language_id) }

      # The top level public, non-fixed elements of this page that - if present -
      # contains their nested_elements.
      def elements
        @_elements ||= first_level_elements.reject(&:fixed?)
      end

      # The top level public, fixed elements of this page that - if present -
      # contains their nested_elements.
      def fixed_elements
        @_fixed_elements ||= first_level_elements.select(&:fixed?)
      end

      def element_ids
        @_element_ids ||= elements.map(&:id)
      end

      def fixed_element_ids
        @_fixed_element_ids ||= fixed_elements.map(&:id)
      end

      private

      def first_level_elements
        @_first_level_elements ||= all_elements.reject(&:parent_element_id)
      end
    end
  end
end
