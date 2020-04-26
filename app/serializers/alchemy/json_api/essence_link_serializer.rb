require "alchemy/json_api/essence_serializer"

module Alchemy::JsonApi
  class EssenceLinkSerializer
    include EssenceSerializer
    attribute :title, &:link_title
    attribute :target, &:link_target
    attribute :class_name, &:link_class_name

    link :href, :link

    has_one :content
  end
end
