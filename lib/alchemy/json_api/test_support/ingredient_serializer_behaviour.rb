# frozen_string_literal: true

RSpec.shared_examples "an ingredient serializer" do
  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right transformed keys and values" do
      transform_method = FastJsonapi::ObjectSerializer::TRANSFORMS_MAPPING[Alchemy::JsonApi.key_transform]
      transformed_keys = %w[created_at updated_at].map { |k| k.send(*transform_method).to_sym }

      expect(subject).to have_key(:role)
      expect(subject).to have_key(:type)
      expect(subject[:type]).to eq ingredient.type.tr("::", "").sub!(/(Ingredient)s/, '\1')
      expect(subject).to have_key(:value)
      transformed_keys.each do |transformed_key|
        expect(subject).to have_key(transformed_key)
      end
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
