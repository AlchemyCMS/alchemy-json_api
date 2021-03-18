# frozen_string_literal: true
module Alchemy
  module JsonApi
    module Admin
      class PagesController < JsonApi::PagesController
        prepend_before_action { authorize! :edit_content, Alchemy::Page }

        private

        def page_version
          :draft_version
        end
      end
    end
  end
end
