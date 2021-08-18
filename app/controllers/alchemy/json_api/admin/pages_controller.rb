# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class PagesController < JsonApi::PagesController
        prepend_before_action { authorize! :edit_content, Alchemy::Page }
        before_action :set_current_preview, only: :show

        private

        def set_current_preview
          Alchemy::Page.current_preview = @page
        end

        def last_modified_for(page)
          page.updated_at
        end

        def page_version_type
          :draft_version
        end
      end
    end
  end
end
