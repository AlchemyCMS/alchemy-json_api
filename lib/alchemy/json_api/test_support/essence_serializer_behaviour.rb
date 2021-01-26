# frozen_string_literal: true
RSpec.shared_examples "an essence serializer" do
  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject).to have_key(:ingredient)
      expect(subject[:deprecated]).to be(false)
    end

    context "a deprecated content" do
      let(:content) { FactoryBot.create(:alchemy_content, name: "intro", element: element) }

      before do
        expect(content).to receive(:definition).at_least(:once) do
          {
            name: "intro",
            deprecated: true,
          }
        end
      end

      it "has deprecated attribute set to true" do
        expect(subject[:deprecated]).to eq(true)
      end
    end
  end

  describe "relationships" do
    subject { serializer.serializable_hash[:data][:relationships] }

    it "has the right keys and values" do
      expect(subject[:element]).to eq(data: { id: essence.element.id.to_s, type: :element })
    end
  end
end
