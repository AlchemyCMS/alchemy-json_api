# frozen_string_literal: true

module Alchemy
  module JsonApi
    # Lets the layout pages show endpoints find a page by its page layout
    # name in addition to its id or urlname, e.g. +/jsonapi/layout_pages/footer+.
    #
    # Layout pages are usually referenced by their page layout, because their
    # urlname is derived from a name editors can change. Before, clients had
    # to use the index endpoint with a +page_layout_eq+ filter to get them.
    #
    # Lookups by id and urlname take precedence. If more than one layout page
    # with the same page layout exists in a language (i.e. the layout is not
    # +unique+), the first one is returned.
    module FindLayoutPageByPageLayout
      private

      def load_page_for_cache_key
        super
      rescue ActiveRecord::RecordNotFound
        @page = page_scope.find_by!(page_layout: params[:path])
      end

      def load_page_by_urlname
        super || page_scope_with_includes.find_by(page_layout: params[:path])
      end
    end
  end
end
