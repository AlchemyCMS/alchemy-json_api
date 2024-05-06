# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientFileSerializer do
  let(:ingredient) { FactoryBot.build_stubbed(:alchemy_ingredient_file, title: "File", css_class: "custom") }
  let(:attachment) { FactoryBot.build_stubbed(:alchemy_attachment) }

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    context "With attachment set" do
      before do
        allow(ingredient).to receive(:attachment) { attachment }
      end

      it "has the right keys and values" do
        expect(subject[:value]).to eq("/attachment/#{attachment.id}/show.png")
        expect(subject[:link_title]).to eq("File")
        expect(subject[:attachment_name]).to eq("image")
        expect(subject[:attachment_file_name]).to eq("image.png")
        expect(subject[:attachment_mime_type]).to eq("image/png")
        expect(subject[:attachment_file_size]).to eq(70)
      end
    end
  end

  context "With no attachment set" do
    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:attachment_name]).to be_nil
        expect(subject[:attachment_file_name]).to be_nil
        expect(subject[:attachment_mime_type]).to be_nil
        expect(subject[:attachment_file_size]).to be_nil
      end
    end
  end
end
