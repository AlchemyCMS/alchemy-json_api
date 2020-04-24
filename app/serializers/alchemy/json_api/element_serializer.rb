module Alchemy::JsonApi
  class ElementSerializer
    include FastJsonapi::ObjectSerializer
    attributes(
      :name,
      :tag_list,
      :created_at,
      :updated_at
    )
    attribute :display_name, &:display_name_with_preview_text

    belongs_to :page
  end
end
