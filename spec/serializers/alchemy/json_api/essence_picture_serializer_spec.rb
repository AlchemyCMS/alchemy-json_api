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
      css_class: "custom",
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
      expect(subject[:css_class]).to eq("custom")
      expect(subject[:name]).to eq("image")
      expect(subject[:file_name]).to eq("image.png")
      expect(subject[:mime_type]).to eq("image/png")
      expect(subject[:size]).to eq(70)
      expect(subject[:dimensions]).to eq(height: 1, width: 1)
      expect(subject[:tag_list]).to eq([])
    end
  end

  describe "links" do
    subject { serializer.serializable_hash[:data][:links] }

    it "has the right keys and values" do
      expect(subject[:url]).to match(/\/pictures\/\w+\/image\.png\?sha=\w+/)
      expect(subject[:href]).to eq("/hello")
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
  end
end
