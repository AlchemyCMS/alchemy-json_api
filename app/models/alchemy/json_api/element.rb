module Alchemy
  module JsonApi
    class Element < BaseRecord
      include Alchemy::Logger
      include Alchemy::Element::Definitions
      include Alchemy::Element::ElementContents

      self.table_name = "alchemy_elements"

      belongs_to :page, class_name: "Alchemy::JsonApi::Page", inverse_of: :all_elements
      has_many :contents, class_name: "Alchemy::Content", inverse_of: :element

      scope :available, -> { where(public: true).where.not(position: nil) }

      def parent_element
        page.all_elements.detect do |element|
          element.id == parent_element_id
        end
      end

      def nested_elements
        @_nested_elements ||= begin
          page.all_elements.select do |element|
            element.parent_element_id == id
          end
        end
      end

      def nested_element_ids
        nested_elements.map(&:id)
      end
    end
  end
end
