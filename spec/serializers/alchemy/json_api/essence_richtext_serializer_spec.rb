require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::EssenceRichtextSerializer do
  let(:content) { FactoryBot.create(:alchemy_content) }
  let(:essence) do
    Alchemy::EssenceRichtext.new(
      body: "<h3>Hello</h3>",
      stripped_body: "Hello",
      content: content,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:body]).to eq("<h3>Hello</h3>")
      expect(subject[:stripped_body]).to eq("Hello")
    end
  end
end
