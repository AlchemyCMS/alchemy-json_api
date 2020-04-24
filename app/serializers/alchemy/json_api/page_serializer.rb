module Alchemy
  module JsonApi
    class PageSerializer
      include FastJsonapi::ObjectSerializer
      attributes(
        :name,
        :urlname,
        :page_layout,
        :title,
        :language_code,
        :meta_keywords,
        :meta_description,
        :tag_list,
        :created_at,
        :updated_at,
        :status
      )
    end
  end
end
