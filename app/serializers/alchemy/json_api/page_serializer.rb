# frozen_string_literal: true
module Alchemy
  module JsonApi
    class PageSerializer
      include JSONAPI::Serializer

      attributes(
        :name,
        :urlname,
        :page_layout,
        :title,
        :language_code,
        :meta_keywords,
        :meta_description,
        :created_at,
        :updated_at,
      )

      belongs_to :language, record_type: :language, serializer: ::Alchemy::JsonApi::LanguageSerializer

      has_many :elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer
      has_many :fixed_elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer

      has_many :all_elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer do |page|
        page.all_elements.select { |e| e.public? && !e.trashed? }
      end
    end
  end
end
