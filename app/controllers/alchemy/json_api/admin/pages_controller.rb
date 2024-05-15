# frozen_string_literal: true

module Alchemy
  module JsonApi
    module Admin
      class PagesController < JsonApi::PagesController
        prepend_before_action { authorize! :edit_content, Alchemy::Page }
        before_action :set_current_preview, only: :show

        private

        def cache_duration
          0
        end

        def caching_options
          {public: false, must_revalidate: true}
        end

        def set_current_preview
          if Alchemy.const_defined?(:Current)
            Alchemy::Current.preview_page = @page
          else
            Alchemy::Page.current_preview = @page
          end
        end

        def page_cache_key(page)
          page.updated_at
        end

        def page_version_type
          :draft_version
        end
      end
    end
  end
end
