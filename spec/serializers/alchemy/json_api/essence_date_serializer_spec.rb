# frozen_string_literal: true
require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssenceDateSerializer do
  let(:today) { Date.today }
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) { Alchemy::EssenceDate.create(date: today, content: content) }
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence serializer"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:ingredient]).to eq(today)
    end
  end
end
