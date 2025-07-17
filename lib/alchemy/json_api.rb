# frozen_string_literal: true

require "fast_jsonapi"
require "alchemy_cms"
require "alchemy/json_api/engine"

module Alchemy
  module JsonApi
    extend self

    # Set FastJsonapi key_transform
    #
    # Supported transformations:
    #
    # :camel # "some_key" => "SomeKey"
    # :camel_lower # "some_key" => "someKey"
    # :dash # "some_key" => "some-key"
    # :underscore # "some_key" => "some_key"
    def key_transform=(value)
      @_key_transform = value
    end

    # FastJsonapi key_transform
    #
    # Default :underscore # "some_key" => "some_key"
    def key_transform
      @_key_transform || :underscore
    end

    # HTTP Cache-Control max-age
    #
    # Can be set as `ALCHEMY_JSON_API_CACHE_DURATION` env var
    #
    # Default 600 (seconds)
    def page_cache_max_age
      @_page_cache_max_age ||= ENV.fetch("ALCHEMY_JSON_API_CACHE_DURATION", 600).to_i
    end

    def page_cache_max_age=(max_age)
      @_page_cache_max_age = max_age
    end

    # HTTP Cache-Control options
    #
    # Set any of the ActionController::ConditionalGet#expires_in options
    #
    # See https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-expires_in
    #
    # Default `{must_revalidate: true}`
    def page_caching_options
      @_page_caching_options ||= {
        must_revalidate: true
      }
    end

    def page_caching_options=(options)
      @_page_caching_options = options
    end
  end
end
