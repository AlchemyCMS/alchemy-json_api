module Alchemy
  module JsonApi
    class NodeSerializer
      include FastJsonapi::ObjectSerializer

      attributes :name
      attribute :link_url, &:url
      attribute :link_title, &:title
      attribute :link_nofollow, &:nofollow

      belongs_to :parent, record_type: :node
      belongs_to :left_sibling, record_type: :node, serializer: self do |node|
        node.left_sibling
      end

      belongs_to :right_sibling, record_type: :node, serializer: self do |node|
        node.right_sibling
      end

      has_many :children, record_type: :node, serializer: self
      has_many :descendants, record_type: :node, serializer: self do |node|
        node.descendants
      end
    end
  end
end
