# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::PageSerializer do
  let(:alchemy_page) do
    FactoryBot.create(
      :alchemy_page,
      :public,
      urlname: "a-page",
      title: "Page Title",
      meta_keywords: "Meta Keywords",
      meta_description: "Meta Description",
      tag_list: "Tag1,Tag2",
    )
  end
  let!(:legacy_url) { Alchemy::LegacyPageUrl.create(urlname: "/other", page: alchemy_page) }
  let(:options) { {} }
  let(:page) { Alchemy::JsonApi::Page.new(alchemy_page) }

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
      expect(attributes[:legacy_urls]).to eq(["/other"])
      expect(attributes.keys).not_to include(:tag_list, :status)
    end
  end

  describe "relationships" do
    let!(:element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version) }
    let!(:fixed_element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version, fixed: true) }
    let!(:non_public_element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version, public: false) }

    subject { serializer.serializable_hash[:data][:relationships] }

    describe "elements" do
      it "does not include trashed, fixed or hidden elements" do
        expect(subject[:elements]).to eq(
          data: [
            { id: element.id.to_s, type: :element },
          ],
        )
        expect(subject[:language]).to eq(data: { id: page.language_id.to_s, type: :language })
      end
    end

    describe "fixed_elements" do
      it "does not include trashed, non-fixed or hidden elements" do
        expect(subject[:fixed_elements]).to eq(
          data: [
            { id: fixed_element.id.to_s, type: :element },
          ],
        )
        expect(subject[:language]).to eq(data: { id: page.language_id.to_s, type: :language })
      end
    end

    it "has ancestors relationship" do
      expect(subject[:ancestors]).to eq(
        data: [
          { id: page.parent_id.to_s, type: :page },
        ],
      )
    end
  end
end
