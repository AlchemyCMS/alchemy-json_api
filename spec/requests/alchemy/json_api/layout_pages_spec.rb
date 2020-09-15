# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories/page_factory"
require "alchemy/test_support/factories/element_factory"

RSpec.describe "Alchemy::JsonApi::Pages", type: :request do
  let(:page) do
    FactoryBot.create(
      :alchemy_page,
      :public,
      :layoutpage,
      urlname: nil,
      title: "Footer"
    )
  end

  describe "GET /alchemy/json_api/pages/:id" do
    it "gets a valid JSON:API document" do
      get alchemy_json_api.layout_page_path(page)
      expect(response).to have_http_status(200)
      document = JSON.parse(response.body)
      expect(document["data"]).to have_id(page.id.to_s)
      expect(document["data"]).to have_type("page")
    end

    context "when requesting a content page" do
      let(:page) { FactoryBot.create(:alchemy_page, :public, elements: [element]) }
      let(:element) { FactoryBot.create(:alchemy_element, name: "article", autogenerate_contents: true) }

      it "returns a 404" do
        get alchemy_json_api.layout_page_path(page)
        expect(response).to have_http_status(404)
      end
    end

    context "when requesting a URL" do
      it "finds the page" do
        get alchemy_json_api.layout_page_path(page.urlname)
        expect(response).to have_http_status(200)
        document = JSON.parse(response.body)
        expect(document["data"]).to have_id(page.id.to_s)
        expect(document["data"]).to have_type("page")
      end
    end

    context "when the language is incorrect" do
      let!(:language) { FactoryBot.create(:alchemy_language) }
      let!(:other_language) { FactoryBot.create(:alchemy_language, :german) }
      let(:page) { FactoryBot.create(:alchemy_page, :public, :layoutpage, language: other_language) }

      it "returns a 404" do
        get alchemy_json_api.layout_page_path(page.urlname)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "GET /alchemy/json_api/pages" do
    let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
    let!(:non_public_layout_page) { FactoryBot.create(:alchemy_page, :layoutpage) }
    let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

    it "displays the layoutpage and the public page" do
      get alchemy_json_api.layout_pages_path
      document = JSON.parse(response.body)
      expect(document["data"]).to include(have_id(layoutpage.id.to_s))
      expect(document["data"]).not_to include(have_id(non_public_layout_page.id.to_s))
      expect(document["data"]).not_to include(have_id(public_page.id.to_s))
    end
  end
end
