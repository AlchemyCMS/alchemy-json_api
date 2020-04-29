require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::EssenceFileSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) { FactoryBot.create(:alchemy_essence_file, title: "File", css_class: "custom", content: content) }
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:ingredient]).to eq("/attachment/#{essence.attachment_id}/download/image.png")
      expect(subject[:link_title]).to eq("File")
      expect(subject[:attachment_name]).to eq("image")
      expect(subject[:attachment_file_name]).to eq("image.png")
      expect(subject[:attachment_mime_type]).to eq("image/png")
      expect(subject[:attachment_file_size]).to eq(70)
    end
  end

  context "With no file set" do
    let(:essence) do
      FactoryBot.create(
        :alchemy_essence_file,
        content: content,
        attachment: nil,
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
