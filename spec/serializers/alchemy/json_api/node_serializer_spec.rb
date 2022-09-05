# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::NodeSerializer do
  let(:node) do
    FactoryBot.create(
      :alchemy_node,
      name: "A Node",
      url: "/acdc",
      title: "Pop-up explanation",
      nofollow: true,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(node, options) }

  describe "#to_serializable_hash" do
    subject { serializer.serializable_hash }

    it "has the right keys and values" do
      attributes = subject[:data][:attributes]
      expect(attributes[:name]).to eq("A Node")
      expect(attributes[:link_title]).to eq("Pop-up explanation")
      expect(attributes[:link_url]).to eq("/acdc")
      expect(attributes[:link_nofollow]).to be true
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    context "with children" do
      let(:node) do
        FactoryBot.create(
          :alchemy_node,
          name: "A Node",
          url: "/acdc",
          title: "Pop-up explanation",
          nofollow: true,
          children: [child_node],
        )
      end

      let(:child_node) { FactoryBot.create(:alchemy_node, children: [child_of_child_node]) }
      let(:child_of_child_node) { FactoryBot.create(:alchemy_node) }

      it "has children" do
        expect(subject[:children]).to eq(data: [{ id: child_node.id.to_s, type: :node }])
      end
    end

    context "with page assigned" do
      let(:node) do
        FactoryBot.create(
          :alchemy_node,
          name: "A Node",
          url: "/acdc",
          title: "Pop-up explanation",
          nofollow: true,
          page: page,
        )
      end

      let(:page) { FactoryBot.create(:alchemy_page) }

      it "has page" do
        expect(subject[:page]).to eq(data: { id: page.id.to_s, type: :page })
      end
    end
  end
end
