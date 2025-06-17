# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientPageSerializer do
  let(:ingredient) { FactoryBot.create(:alchemy_ingredient_page, page: page) }
  let(:page) { FactoryBot.create(:alchemy_page) }

  let(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  subject { serializer.serializable_hash[:data][:attributes] }

  describe "attributes" do
    it "has page url as ingredient" do
      expect(subject[:value]).to eq(page.url_path)
    end

    it "has page_name" do
      expect(subject[:page_name]).to eq(page.name)
    end

    it "has page_url" do
      expect(subject[:page_url]).to eq(page.url_path)
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has page object" do
      expect(subject[:page]).to eq(data: {id: page.id.to_s, type: :page})
    end
  end

  context "With no page set" do
    let(:page) { nil }

    describe "attributes" do
      it "has no value" do
        expect(subject[:value]).to be_nil
      end

      it "has no page_name" do
        expect(subject[:page_name]).to be_nil
      end

      it "has no page_url" do
        expect(subject[:page_url]).to be_nil
      end
    end
  end
end
