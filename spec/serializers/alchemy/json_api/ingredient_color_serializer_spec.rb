# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientColorSerializer do
  let(:ingredient) do
    Alchemy::Ingredients::Color.new(role: "color", value: "green")
  end

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:value]).to eq("green")
    end
  end
end
