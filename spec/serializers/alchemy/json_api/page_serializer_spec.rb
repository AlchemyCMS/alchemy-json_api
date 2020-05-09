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
      expect(attributes[:language_code]).to eq("de")
      expect(attributes[:meta_keywords]).to eq("Meta Keywords")
      expect(attributes[:meta_description]).to eq("Meta Description")
      expect(attributes[:created_at]).to eq(page.created_at)
      expect(attributes[:updated_at]).to eq(page.updated_at)
      expect(attributes.keys).not_to include(:tag_list, :status)
    end

    context "with admin set to true" do
      let(:options) { {params: {admin: true}} }

      it "includes admin-only attributes" do
        attributes = subject[:data][:attributes]
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

  describe "relationships" do
    let(:element) { FactoryBot.create(:alchemy_element) }
    subject { serializer.serializable_hash[:data][:relationships] }

    before do
      page.elements << element
    end

    it "has the right keys and values" do
      expect(subject[:elements]).to eq(data: [{ id: element.id.to_s, type: :element }])
      expect(subject[:all_elements]).to eq(data: [{ id: element.id.to_s, type: :element }])
      expect(subject[:language]).to eq(data: { id: page.language_id.to_s, type: :language })
    end
  end
end
