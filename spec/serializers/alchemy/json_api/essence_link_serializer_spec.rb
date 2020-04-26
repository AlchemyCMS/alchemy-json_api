require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::EssenceLinkSerializer do
  let(:content) { FactoryBot.create(:alchemy_content) }
  let(:essence) do
    Alchemy::EssenceLink.create(
      link: "/hello",
      link_class_name: "custom-link",
      link_target: "_blank",
      link_title: "Greetings!",
      content: content,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:target]).to eq("_blank")
      expect(subject[:class_name]).to eq("custom-link")
      expect(subject[:title]).to eq("Greetings!")
    end
  end

  describe "links" do
    subject { serializer.serializable_hash[:data][:links] }

    it "has the right keys and values" do
      expect(subject[:href]).to eq("/hello")
    end
  end
end
