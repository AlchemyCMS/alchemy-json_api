# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories"

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
      expect(attributes[:id]).to eq(node.id)
      expect(attributes[:name]).to eq("A Node")
      expect(attributes[:link_title]).to eq("Pop-up explanation")
      expect(attributes[:link_url]).to eq("/acdc")
      expect(attributes[:link_nofollow]).to be true
    end
  end

  describe "relationships" do
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

    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:children]).to eq(data: [{ id: child_node.id.to_s, type: :node }])
    end
  end
end
