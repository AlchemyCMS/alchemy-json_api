require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::PageSerializer do
  let(:page) do
    FactoryBot.create(
      :alchemy_page,
      urlname: "a-page",
      title: "Page Title",
      meta_keywords: "Meta Keywords",
      meta_description: "Meta Description",
      tag_list: "Tag1,Tag2",
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(page, options) }

  describe "#to_serializable_hash" do
    subject { serializer.serializable_hash }

    it "has the right keys and values" do
      attributes = subject[:data][:attributes]
      expect(attributes[:urlname]).to eq("a-page")
      expect(attributes[:name]).to eq(page.name)
      expect(attributes[:page_layout]).to eq("standard")
      expect(attributes[:title]).to eq("Page Title")
      expect(attributes[:language_code]).to eq("en")
      expect(attributes[:meta_keywords]).to eq("Meta Keywords")
      expect(attributes[:meta_description]).to eq("Meta Description")
      expect(attributes[:created_at]).to eq(page.created_at)
      expect(attributes[:updated_at]).to eq(page.updated_at)
      expect(attributes[:tag_list]).to eq(["Tag1", "Tag2"])
      expect(attributes[:status]).to eq(
        {
          public: false,
          locked: false,
          restricted: false,
          visible: false,
        }
      )
    end
  end
end
