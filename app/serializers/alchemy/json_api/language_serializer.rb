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

      has_many :menu_items, record_type: :node, serializer: ::Alchemy::JsonApi::NodeSerializer, object_method_name: :nodes, id_method_name: :node_ids, lazy_load_data: true

      has_many :menus, record_type: :node, serializer: ::Alchemy::JsonApi::NodeSerializer, lazy_load_data: true do |language|
        language.nodes.select { |n| n.parent.nil? }
      end
      has_many :pages, lazy_load_data: true
      has_one :root_page, record_type: :page, serializer: ::Alchemy::JsonApi::PageSerializer, lazy_load_data: true
    end
  end
end
