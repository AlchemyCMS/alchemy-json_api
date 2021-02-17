# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssenceRichtextSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) do
    Alchemy::EssenceRichtext.create(
      body: "<h3>Hello</h3>",
      stripped_body: "Hello",
      content: content,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:body]).to eq("<h3>Hello</h3>")
      expect(subject[:stripped_body]).to eq("Hello")
    end
  end
end
