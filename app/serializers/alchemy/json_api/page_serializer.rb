# frozen_string_literal: true

module Alchemy
  module JsonApi
    class PageSerializer < BaseSerializer
      ELEMENT_SERIALIZER = ::Alchemy::JsonApi::ElementSerializer

      attributes(
        :name,
        :urlname,
        :url_path,
        :page_layout,
        :language_code,
        :created_at,
        :updated_at,
        :restricted
      )

      cache_options store: Rails.cache, namespace: "alchemy-jsonapi"

      attribute :legacy_urls do |page|
        page.legacy_urls.map(&:urlname)
      end

      %i[title meta_keywords meta_description].each do |attr_name|
        attribute attr_name do |page|
          case page.page_version_type
          when :public_version
            page.public_version&.send(attr_name)
          else
            page.draft_version.send(attr_name)
          end
        end
      end

      belongs_to :language, record_type: :language, serializer: ::Alchemy::JsonApi::LanguageSerializer

      has_many :ancestors, record_type: :page, serializer: self do |page|
        page.ancestors.map do |ancestor|
          Alchemy::JsonApi::Page.new(ancestor, page_version_type: page.page_version_type)
        end
      end

      # All public elements of this page regardless of if they are fixed or nested.
      # Used for eager loading and should be used as the +include+ parameter of your query
      has_many :all_elements, record_type: :element, serializer: ELEMENT_SERIALIZER

      # The top level public, non-fixed elements of this page that - if present -
      # contains their nested_elements.
      has_many :elements, record_type: :element, serializer: ELEMENT_SERIALIZER

      # The top level public, fixed elements of this page that - if present -
      # contains their nested_elements.
      has_many :fixed_elements, record_type: :element, serializer: ELEMENT_SERIALIZER
    end
  end
end
