# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientDatetimeSerializer do
  let(:today) { Date.today }
  let(:ingredient) { FactoryBot.build_stubbed(:alchemy_ingredient_datetime, value: today) }

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:value]).to eq(today)
    end
  end
end
