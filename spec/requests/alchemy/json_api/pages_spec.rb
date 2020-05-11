# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories/page_factory"
require "alchemy/test_support/factories/element_factory"

RSpec.describe "Alchemy::JsonApi::Pages", type: :request do
  let(:page) do
    FactoryBot.create(
      :alchemy_page,
      :public,
      urlname: "a-page",
      title: "Page Title",
      meta_keywords: "Meta Keywords",
      meta_description: "Meta Description",
      tag_list: "Tag1,Tag2",
    )
  end

  describe "GET /alchemy/json_api/pages/:id" do
    it "gets a valid JSON:API document" do
      get alchemy_json_api.page_path(page)
      expect(response).to have_http_status(200)
      document = JSON.parse(response.body)
      expect(document["data"]).to have_id(page.id.to_s)
      expect(document["data"]).to have_type("page")
    end

    context "when including elements and essences" do
      let(:page) { FactoryBot.create(:alchemy_page, :public, elements: [element]) }
      let(:element) { FactoryBot.create(:alchemy_element, name: "article", autogenerate_contents: true) }

      it "includes the data" do
        get alchemy_json_api.page_path(page, include: "all_elements.essences")
        included = JSON.parse(response.body)["included"]
        expect(included).to include(have_type("element").and(have_id(element.id.to_s)))
      end
    end

    context "when requesting a URL" do
      it "finds the page" do
        get alchemy_json_api.page_path(page.urlname)
        expect(response).to have_http_status(200)
        document = JSON.parse(response.body)
        expect(document["data"]).to have_id(page.id.to_s)
        expect(document["data"]).to have_type("page")
      end
    end

    context "when the language is incorrect" do
      let!(:language) { FactoryBot.create(:alchemy_language) }
      let!(:other_language) { FactoryBot.create(:alchemy_language, :english) }
      let(:page) { FactoryBot.create(:alchemy_page, :public, language: other_language) }

      it "returns a 404" do
        get alchemy_json_api.page_path(page.urlname)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "GET /alchemy/json_api/pages" do
    let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
    let!(:non_public_page) { FactoryBot.create(:alchemy_page) }
    let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

    it "displays the layoutpage and the public page" do
      get alchemy_json_api.pages_path
      document = JSON.parse(response.body)
      expect(document["data"]).not_to include(have_id(layoutpage.id.to_s))
      expect(document["data"]).not_to include(have_id(non_public_page.id.to_s))
      expect(document["data"]).to include(have_id(public_page.id.to_s))
    end
  end
end
