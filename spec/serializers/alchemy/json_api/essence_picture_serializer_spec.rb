require "rails_helper"
require "alchemy/test_support/factories/content_factory"
require "alchemy/test_support/factories/essence_picture_factory"

RSpec.describe Alchemy::JsonApi::EssencePictureSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) do
    FactoryBot.create(
      :alchemy_essence_picture,
      title: "Picture",
      content: content,
      link: "/hello",
    )
  end
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:title]).to eq("Picture")
      expect(subject[:image_name]).to eq("image")
      expect(subject[:image_file_name]).to eq("image.png")
      expect(subject[:image_mime_type]).to eq("image/png")
      expect(subject[:image_file_size]).to eq(70)
      expect(subject[:image_dimensions]).to eq(height: 0, width: 0)
    end
  end

  context "With no picture set" do
    let(:essence) do
      FactoryBot.create(
        :alchemy_essence_picture,
        content: content,
        picture: nil,
      )
    end

    it_behaves_like "an essence"

    describe "attributes" do
      subject { serializer.serializable_hash[:data][:attributes] }

      it "has the right keys and values" do
        expect(subject[:ingredient]).to be nil
      end
    end
  end
end
