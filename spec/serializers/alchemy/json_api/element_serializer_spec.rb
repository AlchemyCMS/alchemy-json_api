require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::ElementSerializer do
  let(:element) do
    FactoryBot.create(
      :alchemy_element,
      autogenerate_contents: true,
      tag_list: "Tag1,Tag2",
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(element, options) }

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:name]).to eq("article")
      expect(subject[:created_at]).to eq(element.created_at)
      expect(subject[:updated_at]).to eq(element.updated_at)
      expect(subject[:tag_list]).to eq(["Tag1", "Tag2"])
      expect(subject[:display_name]).to eq("Article: ")
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:page]).to eq(data: { id: element.page_id.to_s, type: :page })
    end
  end
end
