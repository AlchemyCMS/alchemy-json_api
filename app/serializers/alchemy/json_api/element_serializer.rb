module Alchemy::JsonApi
  class ElementSerializer
    include FastJsonapi::ObjectSerializer
    attributes(
      :position,
      :tag_list,
      :created_at,
      :updated_at
    )
    attribute :display_name, &:display_name_with_preview_text
    attribute :element_type, &:name
    belongs_to :parent_element, record_type: :element

    belongs_to :page
    has_many :essences, polymorphic: true do |element|
      element.contents.map(&:essence)
    end

    has_many :nested_elements, record_type: :element, serializer: self
  end
end
