# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientHeadlineSerializer do
  let(:element) { FactoryBot.build_stubbed(:alchemy_element) }
  let(:ingredient) do
    FactoryBot.build_stubbed(
      :alchemy_ingredient_headline,
      element: element,
      role: "headline",
      value: "Hello you world",
      size: 2,
      level: 3
    )
  end

  let(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  subject { serializer.serializable_hash[:data][:attributes] }

  it do
    is_expected.to match(
      hash_including(
        value: "Hello you world",
        level: 3,
        size: 2
      )
    )
  end

  context "with dom_id", if: Alchemy::Ingredients::Headline.stored_attributes[:data].include?(:dom_id) do
    before do
      ingredient.dom_id = "hello-you-world"
    end

    it "is included in the response" do
      expect(subject[:dom_id]).to eq "hello-you-world"
    end
  end
end
