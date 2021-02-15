require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::Page, type: :model do
  it { should belong_to(:language).class_name("Alchemy::Language") }
  it { should have_many(:all_elements).class_name("Alchemy::JsonApi::Element") }

  describe "scopes" do
    describe ".published" do
      subject(:published) { described_class.published.map(&:id) }

      let!(:public_one) { FactoryBot.create(:alchemy_page, :public) }
      let!(:public_two) { FactoryBot.create(:alchemy_page, :public) }
      let!(:non_public_page) { FactoryBot.create(:alchemy_page) }

      it "returns public available pages" do
        # expecting the ids here because the factorys class is not our decorator class
        expect(published).to include(public_one.id)
        expect(published).to include(public_two.id)
        expect(published).to_not include(non_public_page.id)
      end
    end

    describe ".contentpages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage) }
      let!(:contentpage) { FactoryBot.create(:alchemy_page) }

      it "should return contentpages" do
        # expecting the attribute here because the factorys class is not our decorator class
        expect(described_class.contentpages.map(&:layoutpage)).to eq([false, false]) # page plus root page
      end
    end

    describe ".layoutpages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage) }
      let!(:contentpage) { FactoryBot.create(:alchemy_page) }

      it "should return layoutpages" do
        # expecting the attribute here because the factorys class is not our decorator class
        expect(described_class.layoutpages.map(&:layoutpage)).to eq([true])
      end
    end

    describe ".with_language" do
      let(:english) { FactoryBot.create(:alchemy_language, :english) }
      let(:german) { FactoryBot.create(:alchemy_language, :german) }
      let!(:page_en) { FactoryBot.create(:alchemy_page, language: english) }
      let!(:page_de) { FactoryBot.create(:alchemy_page, language: german) }

      it "should return layoutpages" do
        # expecting the attribute here because the factorys class is not our decorator class
        expect(described_class.with_language(german.id).map(&:language_id)).to eq([german.id, german.id]) # page plus root page
      end
    end
  end

  describe "#all_elements" do
    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element_1) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:element_2) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:element_3) { FactoryBot.create(:alchemy_element, page: page) }

    before do
      element_3.move_to_top
    end

    subject(:all_element_ids) do
      described_class.find(page.id).all_elements.map(&:id)
    end

    it "returns a ordered active record collection of elements on that page" do
      expect(all_element_ids).to eq([element_3.id, element_1.id, element_2.id])
    end

    context "with nestable elements" do
      let!(:nestable_element) do
        FactoryBot.create(:alchemy_element, page: page)
      end

      let!(:nested_element) do
        FactoryBot.create(:alchemy_element, name: "slide", parent_element: nestable_element, page: page)
      end

      it "contains nested elements of an element" do
        expect(all_element_ids).to include(nested_element.id)
      end
    end

    context "with hidden elements" do
      let!(:hidden_element) { FactoryBot.create(:alchemy_element, page: page, public: false) }

      it "does not contain hidden elements" do
        expect(all_element_ids).to_not include(hidden_element.id)
      end
    end

    context "with fixed elements" do
      let!(:fixed_element) { FactoryBot.create(:alchemy_element, page: page, fixed: true) }

      it "contains fixed elements" do
        expect(all_element_ids).to include(fixed_element.id)
      end
    end
  end

  describe "#elements" do
    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element_1) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:element_2) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:element_3) { FactoryBot.create(:alchemy_element, page: page) }
    let!(:fixed_element) { FactoryBot.create(:alchemy_element, page: page, fixed: true) }

    before do
      element_3.move_to_top
    end

    subject(:element_ids) { described_class.find(page.id).elements.map(&:id) }

    it "returns a ordered active record collection of elements on that page" do
      expect(element_ids).to eq([element_3.id, element_1.id, element_2.id])
    end

    context "with nestable elements" do
      let!(:nested_element) { FactoryBot.create(:alchemy_element, page: page, parent_element: element_3) }

      it "does not contain nested elements of an element" do
        expect(element_ids).to_not include(nested_element.id)
      end
    end

    context "with hidden elements" do
      let(:hidden_element) { FactoryBot.create(:alchemy_element, page: page, public: false) }

      it "does not contain hidden elements" do
        expect(element_ids).to_not include(hidden_element.id)
      end
    end
  end

  describe "#fixed_elements" do
    let(:page) { FactoryBot.create(:alchemy_page) }
    let!(:element_1) { FactoryBot.create(:alchemy_element, fixed: true, page: page) }
    let!(:element_2) { FactoryBot.create(:alchemy_element, fixed: true, page: page) }
    let!(:element_3) { FactoryBot.create(:alchemy_element, fixed: true, page: page) }
    let!(:not_fixed) { FactoryBot.create(:alchemy_element, fixed: false, page: page) }

    before do
      element_3.move_to_top
    end

    subject(:fixed_elements) { described_class.find(page.id).fixed_elements.map(&:id) }

    it "returns a ordered active record collection of fixed elements on that page" do
      expect(fixed_elements).to eq([element_3.id, element_1.id, element_2.id])
    end

    context "with hidden fixed elements" do
      let!(:hidden_element) { FactoryBot.create(:alchemy_element, page: page, fixed: true, public: false) }

      it "does not contain hidden fixed elements" do
        expect(fixed_elements).to_not include(hidden_element.id)
      end
    end
  end
end
