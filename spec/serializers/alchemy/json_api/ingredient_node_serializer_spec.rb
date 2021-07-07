# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientNodeSerializer do
  let(:ingredient) { FactoryBot.build_stubbed(:alchemy_ingredient_node, node: node) }
  let(:node) { FactoryBot.build_stubbed(:alchemy_node, title: "Pop-up explanation", url: "/acdc", nofollow: true, children: [child_node]) }
  let(:child_node) { FactoryBot.build_stubbed(:alchemy_node, children: [child_of_child_node]) }
  let(:child_of_child_node) { FactoryBot.build_stubbed(:alchemy_node) }

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:value]).to eq(node.name)
      expect(subject[:name]).to eq("A Node")
      expect(subject[:link_title]).to eq("Pop-up explanation")
      expect(subject[:link_url]).to eq("/acdc")
      expect(subject[:link_nofollow]).to be true
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:node]).to eq(data: { id: node.id.to_s, type: :node })
    end
  end

  context "With no node set" do
    let(:node) { nil }

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:value]).to be_nil
        expect(subject[:name]).to be_nil
        expect(subject[:link_title]).to be_nil
        expect(subject[:link_url]).to be_nil
        expect(subject[:link_nofollow]).to be_nil
      end
    end
  end
end
