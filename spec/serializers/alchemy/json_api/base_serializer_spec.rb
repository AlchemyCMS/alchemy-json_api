# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::JsonApi::BaseSerializer do
  it { expect(described_class).to be < JSONAPI::Serializer }

  it "sets key_transform" do
    expect(described_class).to receive(:set_key_transform).with(:underscore)
    load Alchemy::JsonApi::Engine.root.join("app/serializers/alchemy/json_api/base_serializer.rb")
  end

  describe ".typelize" do
    let(:parent) { Class.new(described_class) { typelize(name: "string") } }
    let(:child) { Class.new(parent) { typelize(position: "number") } }

    it "merges the types into the inherited ones" do
      expect(child.typelized_attributes).to eq("name" => "string", "position" => "number")
    end

    it "does not change the types of the parent" do
      child
      expect(parent.typelized_attributes).to eq("name" => "string")
    end
  end
end
