# frozen_string_literal: true
require "alchemy/json_api/essence_serializer"

module Alchemy
  module JsonApi
    class EssenceDateSerializer < BaseSerializer
      include EssenceSerializer
    end
  end
end
