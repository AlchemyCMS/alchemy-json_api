# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::BaseSerializer do
  it { expect(described_class).to be < JSONAPI::Serializer }

  it "sets key_transform" do
    expect(described_class).to receive(:set_key_transform).with(:underscore)
    load Alchemy::JsonApi::Engine.root.join("app/serializers/alchemy/json_api/base_serializer.rb")
  end

  describe ".preload_relations" do
    subject { described_class.preload_relations }

    it { is_expected.to eq([]) }
  end
end
