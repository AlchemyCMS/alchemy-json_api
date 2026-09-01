# frozen_string_literal: true

require "rails_helper"

# Covers the FastJsonapi::SerializationCore patch that makes `lazy_load_data`
# honour nested includes (loaded from the engine). Because the patch vendors a
# verbatim copy of upstream's `get_included_records`, these specs also pin the
# copied behaviour we now own: sideloading, deduplication, deep nesting and
# has_many relationships.
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

  # Relationship without lazy_load_data -- must be unaffected by the patch.
  class EagerSerializer
    include JSONAPI::Serializer

    set_type :eager
    belongs_to(:leaf, serializer: LeafSerializer) { |r| r.leaf }
  end

  # Self-referential, like Alchemy's nested_elements, to exercise depth >= 3.
  class TreeSerializer
    include JSONAPI::Serializer

    set_type :tree
    attribute(:name) { |r| r.name }
    belongs_to(:child, serializer: TreeSerializer, lazy_load_data: true) { |r| r.child }
  end

  # Two relationships pointing at the same record, to exercise deduplication.
  class SharedRefSerializer
    include JSONAPI::Serializer

    set_type :shared_ref
    belongs_to(:first, serializer: LeafSerializer, lazy_load_data: true) { |r| r.shared }
    belongs_to(:second, serializer: LeafSerializer, lazy_load_data: true) { |r| r.shared }
  end

  class CollectionSerializer
    include JSONAPI::Serializer

    set_type :collection
    has_many(:leaves, serializer: LeafSerializer, lazy_load_data: true) { |r| r.leaves }
    has_many(:others, serializer: LeafSerializer, lazy_load_data: true) { |r| r.others }
  end

  # Nested has_many, mirroring the real all_elements.ingredients shape.
  class CollectionRootSerializer
    include JSONAPI::Serializer

    set_type :collection_root
    belongs_to(:child, serializer: CollectionSerializer, lazy_load_data: true) { |r| r.child }
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

  def included_of(hash, type)
    Array(hash[:included]).select { |r| r[:type] == type }
  end

  it "emits data for a requested nested relationship" do
    hash = LazyLoadDataNestedSpec::RootSerializer.new(root, include: ["parent.wanted"]).serializable_hash
    expect(relationship(hash, :parent, "10", :wanted)).to have_key(:data)
  end

  it "omits data for an unrequested nested relationship" do
    hash = LazyLoadDataNestedSpec::RootSerializer.new(root, include: ["parent.wanted"]).serializable_hash
    expect(relationship(hash, :parent, "10", :unwanted)).not_to have_key(:data)
  end

  it "leaves relationships without lazy_load_data untouched" do
    record = LazyLoadDataNestedSpec::Record.new(
      id: "1",
      leaf: LazyLoadDataNestedSpec::Record.new(id: "9", name: "x")
    )
    hash = LazyLoadDataNestedSpec::EagerSerializer.new(record).serializable_hash
    expect(hash.dig(:data, :relationships, :leaf)).to have_key(:data)
  end

  context "with a deep (3-level) include path" do
    let(:tree) do
      r = LazyLoadDataNestedSpec::Record
      r.new(id: "1", name: "a", child:
        r.new(id: "2", name: "b", child:
          r.new(id: "3", name: "c", child:
            r.new(id: "4", name: "d", child: nil))))
    end

    let(:hash) do
      LazyLoadDataNestedSpec::TreeSerializer.new(tree, include: ["child.child.child"]).serializable_hash
    end

    it "emits linkage at every requested level" do
      expect(relationship(hash, :tree, "1", :child)).to eq(data: {id: "2", type: :tree})
      expect(relationship(hash, :tree, "2", :child)).to eq(data: {id: "3", type: :tree})
      expect(relationship(hash, :tree, "3", :child)).to eq(data: {id: "4", type: :tree})
    end

    it "stops emitting linkage once the include path is exhausted" do
      expect(relationship(hash, :tree, "4", :child)).not_to have_key(:data)
    end

    it "sideloads every node along the path" do
      expect(included_of(hash, :tree).map { |r| r[:id] }).to contain_exactly("2", "3", "4")
    end
  end

  context "when a record is referenced by two relationships" do
    let(:record) do
      LazyLoadDataNestedSpec::Record.new(
        id: "1",
        shared: LazyLoadDataNestedSpec::Record.new(id: "500", name: "shared")
      )
    end

    let(:hash) do
      LazyLoadDataNestedSpec::SharedRefSerializer.new(record, include: ["first", "second"]).serializable_hash
    end

    it "sideloads the shared record only once" do
      expect(included_of(hash, :leaf).map { |r| r[:id] }).to eq(["500"])
    end

    it "emits linkage on both relationships" do
      expect(hash.dig(:data, :relationships, :first)).to eq(data: {id: "500", type: :leaf})
      expect(hash.dig(:data, :relationships, :second)).to eq(data: {id: "500", type: :leaf})
    end
  end

  context "with a nested has_many relationship" do
    let(:record) do
      r = LazyLoadDataNestedSpec::Record
      r.new(id: "1", child:
        r.new(id: "10",
          leaves: [r.new(id: "100", name: "a"), r.new(id: "101", name: "b")],
          others: [r.new(id: "200", name: "c")]))
    end

    let(:hash) do
      LazyLoadDataNestedSpec::CollectionRootSerializer.new(record, include: ["child.leaves"]).serializable_hash
    end

    it "emits data for the requested has_many" do
      expect(relationship(hash, :collection, "10", :leaves)).to eq(
        data: [{id: "100", type: :leaf}, {id: "101", type: :leaf}]
      )
    end

    it "omits data for an unrequested sibling has_many" do
      expect(relationship(hash, :collection, "10", :others)).not_to have_key(:data)
    end

    it "sideloads only the requested collection's members" do
      expect(included_of(hash, :leaf).map { |r| r[:id] }).to contain_exactly("100", "101")
    end
  end
end

RSpec.describe "vendored FastJsonapi::SerializationCore" do
  it "matches the upstream version get_included_records was copied from" do
    expect(Gem.loaded_specs["jsonapi-serializer"].version.to_s).to(eq("2.2.0"), <<~MSG)
      SerializationCorePatch#get_included_records is a verbatim copy of
      jsonapi-serializer 2.2.0. This spec fails on a version bump so the copy
      gets re-diffed against upstream before shipping.
    MSG
  end
end
