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
      expect(subject[:link_url]).to eq("/hello")
      expect(subject[:link_target]).to eq("_blank")
      expect(subject[:link_title]).to eq("Warm Greetings")
    end
  end
end
