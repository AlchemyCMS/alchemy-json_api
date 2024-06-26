# frozen_string_literal: true

module Alchemy
  module JsonApi
    class LanguageSerializer < BaseSerializer
      attributes(
        :name,
        :language_code,
        :country_code,
        :locale
      )

      has_many :menu_items, record_type: :node, serializer: ::Alchemy::JsonApi::NodeSerializer, object_method_name: :nodes, id_method_name: :node_ids

      has_many :menus, record_type: :node, serializer: ::Alchemy::JsonApi::NodeSerializer do |language|
        language.nodes.select { |n| n.parent.nil? }
      end
      has_many :pages
      has_one :root_page, record_type: :page, serializer: ::Alchemy::JsonApi::PageSerializer
    end
  end
end
