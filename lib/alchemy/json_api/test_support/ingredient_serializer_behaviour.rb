# frozen_string_literal: true

RSpec.shared_examples "an ingredient serializer" do
  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right transformed keys and values" do
      expect(subject).to have_key(:role)
      expect(subject).to have_key(:value)
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
end
