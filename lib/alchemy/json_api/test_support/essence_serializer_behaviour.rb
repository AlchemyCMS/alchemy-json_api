# frozen_string_literal: true
RSpec.shared_examples "an essence" do
  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject).to have_key(:ingredient)
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:element]).to eq(data: { id: essence.element.id.to_s, type: :element })
    end
  end
end
