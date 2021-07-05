# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::EssenceHeadlineSerializer do
  let(:element) { FactoryBot.create(:alchemy_element) }
  let(:content) { FactoryBot.create(:alchemy_content, element: element) }
  let(:essence) do
    Alchemy::EssenceHeadline.create(
      content: content,
      body: "Hello you world",
      size: 2,
      level: 3,
    )
  end

  let(:serializer) { described_class.new(essence) }

  it_behaves_like "an essence serializer"

  subject { serializer.serializable_hash[:data][:attributes] }

  it do
    is_expected.to match(
      hash_including(
        ingredient: "Hello you world",
        level: 3,
        size: 2,
      )
    )
  end
end
