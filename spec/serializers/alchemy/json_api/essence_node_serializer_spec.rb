# frozen_string_literal: true
require "rails_helper"
require "alchemy/essence_node"

RSpec.describe Alchemy::JsonApi::EssenceNodeSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) { Alchemy::EssenceNode.create(node: node, content: content) }
  let(:node) { FactoryBot.create(:alchemy_node, title: "Pop-up explanation", url: "/acdc", nofollow: true, children: [child_node]) }
  let(:child_node) { FactoryBot.create(:alchemy_node, children: [child_of_child_node]) }
  let(:child_of_child_node) { FactoryBot.create(:alchemy_node) }
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:ingredient]).to eq(node.name)
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
    let(:essence) { Alchemy::EssenceNode.create(node: nil, content: content) }

    it_behaves_like "an essence serializer"

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:ingredient]).to be nil
      end
    end
  end
end
