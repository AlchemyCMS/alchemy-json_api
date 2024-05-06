# frozen_string_literal: true

module Alchemy
  module JsonApi
    class NodeSerializer < BaseSerializer
      attributes :name
      attribute :link_url, &:url
      attribute :link_title, &:title
      attribute :link_nofollow, &:nofollow

      belongs_to :parent, record_type: :node, serializer: self

      belongs_to(
        :page,
        record_type: :page,
        if: ->(node) { node.page },
        serializer: ::Alchemy::JsonApi::PageSerializer
      ) do |node|
        ::Alchemy::JsonApi::Page.new(node.page)
      end

      has_many :children, record_type: :node, serializer: self
    end
  end
end
