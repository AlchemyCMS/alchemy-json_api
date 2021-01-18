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

      has_many :elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer do |page|
        page.elements.reject { |e| !!e.try(:deprecated?) }
      end

      has_many :fixed_elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer do |page|
        page.fixed_elements.reject { |c| !!c.try(:deprecated?) }
      end

      has_many :all_elements, record_type: :element, serializer: ::Alchemy::JsonApi::ElementSerializer do |page|
        page.all_elements.select { |e| e.public? && !e.trashed? && !e.try(:deprecated?) }
      end

      with_options if: ->(_, params) { params[:admin] == true } do
        attribute :tag_list
        attribute :status
      end
    end
  end
end
