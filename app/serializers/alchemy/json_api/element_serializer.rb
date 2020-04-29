module Alchemy::JsonApi
  class ElementSerializer
    include FastJsonapi::ObjectSerializer
    attributes(
      :tag_list,
      :created_at,
      :updated_at
    )
    attribute :display_name, &:display_name_with_preview_text
    attribute :element_type, &:name

    belongs_to :page
    has_many :essences, polymorphic: true do |element|
      element.contents.map(&:essence)
    end
  end
end
