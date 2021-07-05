# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssencePictureSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:picture) { FactoryBot.create(:alchemy_picture, image_file_size: 301) }
  let(:essence) do
    FactoryBot.create(
      :alchemy_essence_picture,
      title: "Picture",
      content: content,
      link: "/hello",
      picture: picture
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:title]).to eq("Picture")
      expect(subject[:ingredient]).to match(/pictures\/\w+\/image.png/)
      expect(subject[:image_name]).to eq("image")
      expect(subject[:image_file_name]).to eq("image.png")
      expect(subject[:image_mime_type]).to eq("image/png")
      expect(subject[:image_file_size]).to eq(301)
      expect(subject[:image_dimensions]).to eq(width: 1, height: 1)
    end

    describe "image_dimensions" do
      let(:image_dimensions) { subject[:image_dimensions] }

      context "without image" do
        let(:picture) { nil }

        it { expect(image_dimensions).to be_nil }
      end

      context "with image" do
        it do
          expect(image_dimensions).to eq(width: 1, height: 1)
        end

        context "with content settings[:size]" do
          before do
            expect(content).to receive(:settings).at_least(:once) { size }
          end

          let(:size) do
            { size: "100x100" }
          end

          it do
            expect(image_dimensions).to eq(width: 100, height: 100)
          end

          context "without y dimension" do
            let(:size) do
              { size: "100x" }
            end

            it "infers height from ratio" do
              expect(image_dimensions).to eq(width: 100, height: 100)
            end
          end

          context "without x dimension" do
            let(:size) do
              { size: "x50" }
            end

            it "infers width from ratio" do
              expect(image_dimensions).to eq(width: 50, height: 50)
            end
          end
        end
      end
    end
  end

  context "With no picture set" do
    let(:picture) { nil }

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:ingredient]).to be nil
      end
    end
  end
end
