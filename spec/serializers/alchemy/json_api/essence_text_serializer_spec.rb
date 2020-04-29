require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::EssenceTextSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) { FactoryBot.create(:alchemy_essence_text, content: content, link: "/hello", link_target: '_blank', link_title: "Warm Greetings") }
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:body]).to eq("This is a headline")
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:content]).to eq(data: { id: content.id.to_s, type: :content })
    end
  end

  describe "links" do
    subject { serializer.serializable_hash[:data][:links] }

    it "has the right keys and values" do
      expect(subject[:href]).to eq("/hello")
    end
  end
end
