# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::ElementSerializer do
  let(:element) do
    FactoryBot.create(
      :alchemy_element,
      autogenerate_ingredients: true,
      tag_list: "Tag1,Tag2",
      nested_elements: [nested_element],
      parent_element: parent_element
    )
  end
  let(:nested_element) { FactoryBot.create(:alchemy_element) }
  let(:parent_element) { FactoryBot.create(:alchemy_element) }
  let(:options) { {} }

  subject(:serializer) { described_class.new(element, options) }

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:name]).to eq("article")
      expect(subject[:fixed]).to eq(false)
      expect(subject[:created_at]).to eq(element.created_at)
      expect(subject[:updated_at]).to eq(element.updated_at)
      expect(subject[:position]).to eq(element.position)
      expect(subject[:deprecated]).to eq(false)
      expect(subject.keys).not_to include(:tag_list, :display_name)
    end

    context "a deprecated element" do
      let(:element) do
        FactoryBot.create(:alchemy_element, name: "old")
      end

      it "has deprecated attribute set to true" do
        expect(subject[:deprecated]).to eq(true)
      end
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has nested_elements" do
      expect(subject[:nested_elements]).to eq(data: [{id: nested_element.id.to_s, type: :element}])
    end

    context "with ingredients" do
      before do
        expect(element).to receive(:ingredients) do
          [
            FactoryBot.build_stubbed(:alchemy_ingredient_text, element: element),
            FactoryBot.build_stubbed(:alchemy_ingredient_richtext, element: element),
            FactoryBot.build_stubbed(:alchemy_ingredient_picture, element: element)
          ]
        end
      end

      it "has ingredients" do
        expect(subject[:ingredients]).to eq(
          data: [
            {id: "1001", type: :ingredient_text},
            {id: "1002", type: :ingredient_richtext},
            {id: "1003", type: :ingredient_picture}
          ]
        )
      end
    end
  end
end
