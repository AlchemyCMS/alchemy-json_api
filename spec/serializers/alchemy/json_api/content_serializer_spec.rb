require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::ContentSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:essence) { FactoryBot.create(:alchemy_essence_text) }
  let(:content) do
    FactoryBot.create(
      :alchemy_content,
      name: "headline",
      essence: essence,
      element: element,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(content, options) }

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:name]).to eq("headline")
      expect(subject[:created_at]).to eq(content.created_at)
      expect(subject[:updated_at]).to eq(content.updated_at)
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:essence]).to eq(data: { id: essence.id.to_s, type: :essence_text })
      expect(subject[:element]).to eq(data: { id: content.element_id.to_s, type: :element })
    end
  end
end
