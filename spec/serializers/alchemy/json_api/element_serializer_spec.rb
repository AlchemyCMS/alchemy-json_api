# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::ElementSerializer do
  let(:element) do
    FactoryBot.create(
      :alchemy_element,
      autogenerate_contents: true,
      tag_list: "Tag1,Tag2",
      nested_elements: [nested_element],
      parent_element: parent_element,
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

    it "has the right keys and values" do
      expect(subject[:essences]).to eq(data: element.contents.map { |c| { id: c.essence_id.to_s, type: c.essence.class.name.demodulize.underscore.to_sym } })
      expect(subject[:nested_elements]).to eq(data: [{ id: nested_element.id.to_s, type: :element }])
    end
  end
end
