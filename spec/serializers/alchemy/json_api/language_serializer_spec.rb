# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories/language_factory"
require "alchemy/test_support/factories/page_factory"
require "alchemy/test_support/factories/node_factory"

RSpec.describe Alchemy::JsonApi::LanguageSerializer do
  let(:language) do
    FactoryBot.create(:alchemy_language, :german, country_code: "DE")
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(language, options) }

  describe "#to_serializable_hash" do
    subject { serializer.serializable_hash }

    it "has the right keys and values" do
      attributes = subject[:data][:attributes]
      expect(attributes[:name]).to eq("Deutsch")
      expect(attributes[:language_code]).to eq("de")
      expect(attributes[:country_code]).to eq("DE")
      expect(attributes[:locale]).to eq("de")
    end
  end

  describe "relationships" do
    let!(:root_page) { FactoryBot.create(:alchemy_page, :language_root, language: language) }
    let!(:menu) { FactoryBot.create(:alchemy_node, language: language) }
    let!(:menu_node) { FactoryBot.create(:alchemy_node, language: language, parent: menu) }

    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:root_page]).to eq(data: { id: root_page.id.to_s, type: :page })
      expect(subject[:pages]).to eq(data: [{ id: root_page.id.to_s, type: :page }])
      expect(subject[:menus]).to eq(data: [{ id: menu.id.to_s, type: :node }])
      expect(subject[:menu_items]).to eq(data: [{ id: menu.id.to_s, type: :node }, { id: menu_node.id.to_s, type: :node }])
    end
  end
end
