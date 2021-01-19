# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::PageSerializer do
  let(:alchemy_page) do
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
  let(:page) { Alchemy::JsonApi::Page.find(alchemy_page.id) }

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
      expect(attributes.keys).not_to include(:tag_list, :status)
    end
  end

  describe "relationships" do
    let!(:element) { FactoryBot.create(:alchemy_element, page: alchemy_page) }
    let!(:fixed_element) { FactoryBot.create(:alchemy_element, page: alchemy_page, fixed: true) }
    let!(:non_public_element) { FactoryBot.create(:alchemy_element, page: alchemy_page, public: false) }
    let!(:trashed_element) { FactoryBot.create(:alchemy_element, page: alchemy_page).tap(&:trash!) }

    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values, and does not include trashed or hidden elements" do
      expect(subject[:elements]).to eq(
        data: [
          { id: element.id.to_s, type: :element },
          { id: fixed_element.id.to_s, type: :element },
        ],
      )
      expect(subject[:language]).to eq(data: { id: page.language_id.to_s, type: :language })
    end
  end
end
