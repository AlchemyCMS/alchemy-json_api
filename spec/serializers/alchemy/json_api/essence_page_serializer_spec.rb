# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssencePageSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:page) { FactoryBot.create(:alchemy_page) }
  let(:essence) do
    FactoryBot.create(
      :alchemy_essence_page,
      content: content,
      page: page,
    )
  end
  let(:options) { {} }

  let(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  subject { serializer.serializable_hash[:data][:attributes] }

  describe "attributes" do
    it "has page url as ingredient" do
      expect(subject[:ingredient]).to eq(page.url_path)
    end

    it "has page_name" do
      expect(subject[:page_name]).to eq(page.name)
    end

    it "has page_url" do
      expect(subject[:page_url]).to eq(page.url_path)
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has page object" do
      expect(subject[:page]).to eq(data: { id: page.id.to_s, type: :page })
    end
  end

  context "With no page set" do
    let(:essence) do
      FactoryBot.create(
        :alchemy_essence_page,
        content: content,
        page: nil,
      )
    end

    it_behaves_like "an essence serializer"

    describe "attributes" do
      it "has no ingredient" do
        expect(subject[:ingredient]).to be_nil
      end

      it "has no page_name" do
        expect(subject[:page_name]).to be_nil
      end

      it "has no page_url" do
        expect(subject[:page_url]).to be_nil
      end
    end
  end
end
