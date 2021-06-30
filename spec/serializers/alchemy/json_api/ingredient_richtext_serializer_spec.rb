# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientRichtextSerializer do
  let(:ingredient) do
    FactoryBot.create(
      :alchemy_ingredient_richtext,
      value: "<h3 style=\"color: red;\">Hello</h3>",
    )
  end

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:body]).to eq("<h3 style=\"color: red;\">Hello</h3>")
      expect(subject[:sanitized_body]).to eq("<h3>Hello</h3>")
      expect(subject[:stripped_body]).to eq("Hello")
    end
  end
end
