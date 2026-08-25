# frozen_string_literal: true

require "rails_helper"

# Covers the FastJsonapi::SerializationCore patch that makes `lazy_load_data`
# honour nested includes (loaded from the engine).
module LazyLoadDataNestedSpec
  class Record
    def initialize(**attributes) = @attributes = attributes
    def method_missing(name, *) = @attributes.key?(name) ? @attributes[name] : super
    def respond_to_missing?(name, *) = @attributes.key?(name) || super
  end

  class LeafSerializer
    include JSONAPI::Serializer

    set_type :leaf
    attribute(:name) { |record| record.name }
  end

  class ParentSerializer
    include JSONAPI::Serializer

    set_type :parent
    belongs_to(:wanted, serializer: LeafSerializer, lazy_load_data: true) { |r| r.wanted }
    belongs_to(:unwanted, serializer: LeafSerializer, lazy_load_data: true) { |r| r.unwanted }
  end

  class RootSerializer
    include JSONAPI::Serializer

    set_type :root
    belongs_to(:parent, serializer: ParentSerializer, lazy_load_data: true) { |r| r.parent }
  end

  # Relationship that opts out of lazy loading -- must always emit linkage.
  class EagerSerializer
    include JSONAPI::Serializer

    set_type :eager
    belongs_to(:leaf, serializer: LeafSerializer, lazy_load_data: false) { |r| r.leaf }
  end
end

RSpec.describe "FastJsonapi lazy_load_data patch (nested includes)" do
  let(:root) do
    LazyLoadDataNestedSpec::Record.new(
      id: "1",
      parent: LazyLoadDataNestedSpec::Record.new(
        id: "10",
        wanted: LazyLoadDataNestedSpec::Record.new(id: "100", name: "wanted"),
        unwanted: LazyLoadDataNestedSpec::Record.new(id: "200", name: "unwanted")
      )
    )
  end

  def relationship(hash, type, id, name)
    node = ([hash[:data]] + Array(hash[:included])).find { |r| r && r[:type] == type && r[:id] == id }
    node&.dig(:relationships, name)
  end

  it "emits data for a requested nested relationship" do
    hash = LazyLoadDataNestedSpec::RootSerializer.new(root, include: ["parent.wanted"]).serializable_hash
    expect(relationship(hash, :parent, "10", :wanted)).to have_key(:data)
  end

  it "omits data for an unrequested nested relationship" do
    hash = LazyLoadDataNestedSpec::RootSerializer.new(root, include: ["parent.wanted"]).serializable_hash
    expect(relationship(hash, :parent, "10", :unwanted)).not_to have_key(:data)
  end

  it "still emits linkage for a relationship with lazy_load_data: false" do
    record = LazyLoadDataNestedSpec::Record.new(
      id: "1",
      leaf: LazyLoadDataNestedSpec::Record.new(id: "9", name: "x")
    )
    hash = LazyLoadDataNestedSpec::EagerSerializer.new(record).serializable_hash
    expect(hash.dig(:data, :relationships, :leaf)).to have_key(:data)
  end
end
