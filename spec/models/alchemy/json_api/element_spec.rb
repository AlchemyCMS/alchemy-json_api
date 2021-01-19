require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::Element, type: :model do
  it { should belong_to(:page).class_name("Alchemy::JsonApi::Page") }
  it { should have_many(:contents).class_name("Alchemy::Content") }

  describe "scopes" do
    describe ".available" do
      subject(:available) { described_class.available.map(&:id) }

      let!(:public_one) { FactoryBot.create(:alchemy_element, public: true) }
      let!(:non_public) { FactoryBot.create(:alchemy_element, public: false) }
      let!(:trashed) { FactoryBot.create(:alchemy_element, public: true).tap(&:trash!) }

      it "returns public available elements" do
        # expecting the ids here because the factorys class is not our decorator class
        expect(available).to include(public_one.id)
        expect(available).to_not include(non_public.id)
        expect(available).to_not include(trashed.id)
      end
    end
  end

  describe "#parent_element" do
    subject { nested_element.parent_element }

    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:nested_element) { FactoryBot.create(:alchemy_element, page: page, parent_element: element) }
    let!(:not_nested_element) { FactoryBot.create(:alchemy_element, page: page) }

    it "returns elements parent element" do
      is_expected.to eq(element)
    end
  end

  describe "#nested_elements" do
    subject { element.nested_elements }

    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:nested_element) { FactoryBot.create(:alchemy_element, page: page, parent_element: element) }
    let!(:not_nested_element) { FactoryBot.create(:alchemy_element, page: page) }

    it "returns all nested elements" do
      is_expected.to eq([nested_element])
    end
  end

  describe "#nested_element_ids" do
    subject { element.nested_element_ids }

    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:nested_element) { FactoryBot.create(:alchemy_element, page: page, parent_element: element) }
    let!(:not_nested_element) { FactoryBot.create(:alchemy_element, page: page) }

    it "returns all nested element ids" do
      is_expected.to eq([nested_element.id])
    end
  end
end
