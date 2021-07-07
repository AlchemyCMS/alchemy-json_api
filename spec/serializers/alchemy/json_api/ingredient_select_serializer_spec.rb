# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientSelectSerializer do
  let(:ingredient) { FactoryBot.build_stubbed(:alchemy_ingredient_select, value: "wat") }

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:value]).to eq("wat")
    end
  end
end
