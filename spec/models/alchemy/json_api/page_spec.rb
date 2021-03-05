require "rails_helper"

RSpec.describe Alchemy::JsonApi::Page, type: :model do
  let(:json_api_page) { described_class.new(page) }

  shared_context "with page version present" do
    let(:page) { FactoryBot.create(:alchemy_page, :public) }
    let!(:element_1) { FactoryBot.create(:alchemy_element, page_version: page.public_version) }
    let!(:element_2) { FactoryBot.create(:alchemy_element, page_version: page.public_version) }
    let!(:element_3) { FactoryBot.create(:alchemy_element, page_version: page.public_version) }
    let!(:fixed_element) { FactoryBot.create(:alchemy_element, page_version: page.public_version, fixed: true) }
    let!(:nested_element) { FactoryBot.create(:alchemy_element, page_version: page.public_version, parent_element: element_3) }
    let!(:hidden_element) { FactoryBot.create(:alchemy_element, page_version: page.draft_version, public: false) }

    before do
      element_3.move_to_top
    end
  end

  describe "#all_elements" do
    subject(:elements) { json_api_page.all_elements }

    context "with page version present" do
      include_context "with page version present"

      it "returns a ordered active record collection of all visible elements on that page" do
        is_expected.to match([element_3, fixed_element, nested_element, element_1, element_2])
      end

      context "with draft_version passed as page_version" do
        let(:json_api_page) { described_class.new(page, page_version: :draft_version) }
        let!(:element_4) { FactoryBot.create(:alchemy_element, page_version: page.draft_version) }

        it "contains elements only from draft version" do
          is_expected.to match([element_4])
        end
      end
    end

    context "with page_version not present" do
      let(:page) { FactoryBot.create(:alchemy_page) }
      let(:json_api_page) { described_class.new(page, page_version: :public_version) }

      it "contains elements only from draft version" do
        is_expected.to match([])
      end
    end
  end

  describe "#all_element_ids" do
    subject(:all_element_ids) { json_api_page.all_element_ids }

    include_context "with page version present"

    it "returns a ordered active record collection of element ids on that page" do
      is_expected.to match([element_3.id, fixed_element.id, nested_element.id, element_1.id, element_2.id])
    end
  end

  describe "#elements" do
    subject(:elements) { json_api_page.elements }

    include_context "with page version present"

    it "returns a ordered active record collection of top level not fixed visible elements on that page" do
      is_expected.to match([element_3, element_1, element_2])
    end
  end

  describe "#element_ids" do
    subject(:element_ids) { json_api_page.element_ids }

    include_context "with page version present"

    it "returns a ordered active record collection of top level not fixed visible element ids on that page" do
      is_expected.to match([element_3.id, element_1.id, element_2.id])
    end
  end

  describe "#fixed_elements" do
    subject(:fixed_elements) { json_api_page.fixed_elements }

    include_context "with page version present"

    it "returns a ordered active record collection of top level fixed visible elements on that page" do
      is_expected.to match([fixed_element])
    end
  end

  describe "#fixed_element_ids" do
    subject(:fixed_element_ids) { json_api_page.fixed_element_ids }

    include_context "with page version present"

    it "returns a ordered active record collection of top level fixed visible element ids on that page" do
      is_expected.to match([fixed_element.id])
    end
  end
end
