# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientLinkSerializer do
  let(:ingredient) do
    FactoryBot.build_stubbed(
      :alchemy_ingredient_link,
      value: "/hello",
      link_class_name: "external",
      link_target: "_blank",
      link_title: "Greetings!",
    )
  end

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:value]).to eq("/hello")
      expect(subject[:link_class_name]).to eq("external")
      expect(subject[:link_target]).to eq("_blank")
      expect(subject[:link_title]).to eq("Greetings!")
    end
  end
end
