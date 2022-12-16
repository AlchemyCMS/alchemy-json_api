# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientTextSerializer do
  let(:ingredient) do
    FactoryBot.create(:alchemy_ingredient_text, value: "Welcome")
  end

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:body]).to eq("Welcome")
      expect(subject[:link]).to be_nil
      expect(subject[:link_class_name]).to be_nil
      expect(subject[:link_target]).to be_nil
      expect(subject[:link_title]).to be_nil
    end

    context "with link" do
      before do
        ingredient.link = "https://alchemy-cms.com"
        ingredient.link_class_name = "external"
        ingredient.link_target = "_blank"
        ingredient.link_title = "Great CMS"
      end

      it "has the right keys and values" do
        expect(subject[:link]).to eq "https://alchemy-cms.com"
        expect(subject[:link_class_name]).to eq "external"
        expect(subject[:link_target]).to eq "_blank"
        expect(subject[:link_title]).to eq "Great CMS"
        expect(subject[:link_url]).to eq "https://alchemy-cms.com"
      end
    end

    context "with dom_id", if: Alchemy::Ingredients::Text.stored_attributes[:data].include?(:dom_id) do
      before do
        ingredient.dom_id = "welcome"
      end

      it "is included in the response" do
        expect(subject[:dom_id]).to eq "welcome"
      end
    end
  end
end
