module Alchemy::JsonApi
  class ContentSerializer
    include FastJsonapi::ObjectSerializer
    attributes(
      :name,
      :created_at,
      :updated_at
    )

    belongs_to :essence, polymorphic: true
    belongs_to :element
  end
end
