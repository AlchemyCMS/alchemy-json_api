# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssenceLinkSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) do
    Alchemy::EssenceLink.create(
      link: "/hello",
      link_target: "_blank",
      link_title: "Greetings!",
      content: content,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:ingredient]).to eq("/hello")
      expect(subject[:link_target]).to eq("_blank")
      expect(subject[:link_title]).to eq("Greetings!")
    end
  end
end
