# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TypeScript types of serializers" do
  serializers = Alchemy::JsonApi::Engine.root.glob("app/serializers/alchemy/json_api/*_serializer.rb").map do |path|
    "Alchemy::JsonApi::#{path.basename(".rb").to_s.camelize}".constantize
  end

  serializers.each do |serializer|
    it "declares a type for every attribute of #{serializer.name}" do
      attribute_names = serializer.attributes_to_serialize.to_h.keys.map { _1.to_s.underscore }
      expect(serializer.typelized_attributes.keys).to match_array(attribute_names)
    end
  end
end
