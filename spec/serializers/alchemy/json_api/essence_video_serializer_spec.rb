# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssenceVideoSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:attachment) { FactoryBot.create(:alchemy_attachment) }
  let(:essence) do
    Alchemy::EssenceVideo.create(
      content: content,
      attachment: attachment,
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values", :aggregate_failures do
      expect(subject[:width]).to eq(nil)
      expect(subject[:height]).to eq(nil)
      expect(subject[:allow_fullscreen]).to eq(true)
      expect(subject[:autoplay]).to eq(false)
      expect(subject[:controls]).to eq(true)
      expect(subject[:preload]).to eq(nil)
      expect(subject[:ingredient]).to match(/\/attachment\/#{attachment.id}\/show/o)
      expect(subject[:video_name]).to eq("image")
      expect(subject[:video_file_name]).to eq("image.png")
      expect(subject[:video_mime_type]).to eq("image/png")
      expect(subject[:video_file_size]).to eq(70)
    end
  end

  context "With no video set" do
    let(:essence) do
      Alchemy::EssenceVideo.create(
        content: content,
        attachment: nil,
      )
    end

    it_behaves_like "an essence serializer"

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:ingredient]).to be nil
      end
    end
  end
end
