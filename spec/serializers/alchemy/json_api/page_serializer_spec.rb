# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::PageSerializer do
  let!(:legacy_url) { Alchemy::LegacyPageUrl.create(urlname: "/other", page: alchemy_page) }
  let(:options) { {} }
  let(:page) { Alchemy::JsonApi::Page.new(alchemy_page, page_version_type:) }

  subject(:serializer) { described_class.new(page, options) }

  describe "#to_serializable_hash" do
    subject { serializer.serializable_hash }

    context "for a public page" do
      let(:page_version_type) { :public_version }

      let(:alchemy_page) do
        FactoryBot.create(
          :alchemy_page,
          :public,
          urlname: "a-page",
          tag_list: "Tag1,Tag2"
        ).tap do |page|
          page.public_version.title = "Public Page Title"
          page.public_version.meta_keywords = "public, meta, keywords"
          page.public_version.meta_description = "Public Meta Description"
        end
      end

      it "serializes public keys and values", :aggregate_failures do
        attributes = subject[:data][:attributes]
        expect(attributes[:urlname]).to eq("a-page")
        expect(attributes[:url_path]).to eq("/a-page")
        expect(attributes[:name]).to eq(page.name)
        expect(attributes[:page_layout]).to eq("standard")
        expect(attributes[:title]).to eq("Public Page Title")
        expect(attributes[:language_code]).to eq("en")
        expect(attributes[:meta_keywords]).to eq("public, meta, keywords")
        expect(attributes[:meta_description]).to eq("Public Meta Description")
        expect(attributes[:created_at]).to eq(page.created_at)
        expect(attributes[:updated_at]).to eq(page.updated_at)
        expect(attributes[:legacy_urls]).to eq(["/other"])
        expect(attributes[:restricted]).to be false
        expect(attributes.keys).not_to include(:tag_list, :status)
      end
    end

    context "for a draft page" do
      let(:page_version_type) { :draft_version }

      let(:alchemy_page) do
        FactoryBot.create(
          :alchemy_page,
          urlname: "a-page",
          tag_list: "Tag1,Tag2"
        ).tap do |page|
          page.draft_version.title = "Draft Page Title"
          page.draft_version.meta_keywords = "draft, meta, keywords"
          page.draft_version.meta_description = "Draft Meta Description"
        end
      end

      it "serializes draft keys and values", :aggregate_failures do
        attributes = subject[:data][:attributes]
        expect(attributes[:urlname]).to eq("a-page")
        expect(attributes[:url_path]).to eq("/a-page")
        expect(attributes[:name]).to eq(page.name)
        expect(attributes[:page_layout]).to eq("standard")
        expect(attributes[:title]).to eq("Draft Page Title")
        expect(attributes[:language_code]).to eq("en")
        expect(attributes[:meta_keywords]).to eq("draft, meta, keywords")
        expect(attributes[:meta_description]).to eq("Draft Meta Description")
        expect(attributes[:created_at]).to eq(page.created_at)
        expect(attributes[:updated_at]).to eq(page.updated_at)
        expect(attributes[:legacy_urls]).to eq(["/other"])
        expect(attributes[:restricted]).to be false
        expect(attributes.keys).not_to include(:tag_list, :status)
      end
    end
  end

  describe "relationships" do
    let(:page_version_type) { :public_version }

    let(:alchemy_page) do
      FactoryBot.create(
        :alchemy_page,
        :public,
        urlname: "a-page",
        tag_list: "Tag1,Tag2"
      )
    end

    let!(:element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version) }
    let!(:fixed_element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version, fixed: true) }
    let!(:non_public_element) { FactoryBot.create(:alchemy_element, page_version: alchemy_page.public_version, public: false) }

    subject { serializer.serializable_hash[:data][:relationships] }

    describe "elements" do
      it "does not include trashed, fixed or hidden elements" do
        expect(subject[:elements]).to eq(
          data: [
            {id: element.id.to_s, type: :element}
          ]
        )
        expect(subject[:language]).to eq(data: {id: page.language_id.to_s, type: :language})
      end
    end

    describe "fixed_elements" do
      it "does not include trashed, non-fixed or hidden elements" do
        expect(subject[:fixed_elements]).to eq(
          data: [
            {id: fixed_element.id.to_s, type: :element}
          ]
        )
        expect(subject[:language]).to eq(data: {id: page.language_id.to_s, type: :language})
      end
    end

    it "has ancestors relationship" do
      expect(subject[:ancestors]).to eq(
        data: [
          {id: page.parent_id.to_s, type: :page}
        ]
      )
    end
  end
end
