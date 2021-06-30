# frozen_string_literal: true

RSpec.shared_examples "an ingredient serializer" do
  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject).to have_key(:role)
      expect(subject).to have_key(:value)
      expect(subject).to have_key(:created_at)
      expect(subject).to have_key(:updated_at)
      expect(subject[:deprecated]).to be(false)
    end

    context "a deprecated ingredient" do
      before do
        expect(ingredient).to receive(:deprecated?) { true }
      end

      it "has deprecated attribute set to true" do
        expect(subject[:deprecated]).to eq(true)
      end
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has one element" do
      expect(subject[:element]).to eq(data: { id: ingredient.element_id.to_s, type: :element })
    end
  end
end
