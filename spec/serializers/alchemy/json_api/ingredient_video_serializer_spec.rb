# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::IngredientVideoSerializer do
  let(:element) { FactoryBot.build_stubbed(:alchemy_element) }
  let(:attachment) { FactoryBot.build_stubbed(:alchemy_attachment) }
  let(:ingredient) do
    Alchemy::Ingredients::Video.new(
      role: "video",
      element: element,
      attachment: attachment,
      allow_fullscreen: true,
      autoplay: false,
      controls: true,
    )
  end

  subject(:serializer) { described_class.new(ingredient) }

  it_behaves_like "an ingredient serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values", :aggregate_failures do
      expect(subject[:width]).to eq(nil)
      expect(subject[:height]).to eq(nil)
      expect(subject[:allow_fullscreen]).to eq(true)
      expect(subject[:autoplay]).to eq(false)
      expect(subject[:controls]).to eq(true)
      expect(subject[:preload]).to eq(nil)
      expect(subject[:value]).to match(/\/attachment\/#{attachment.id}\/show/o)
      expect(subject[:video_name]).to eq("image")
      expect(subject[:video_file_name]).to eq("image.png")
      expect(subject[:video_mime_type]).to eq("image/png")
      expect(subject[:video_file_size]).to eq(70)
    end
  end

  context "With no video set" do
    let(:attachment) { nil }

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:ingredient]).to be nil
      end
    end
  end
end
