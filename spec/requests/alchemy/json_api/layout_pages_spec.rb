# frozen_string_literal: true

require "rails_helper"
require "alchemy/devise/test_support/factories"

RSpec.describe "Alchemy::JsonApi::LayoutPagesController", type: :request do
  let(:page) do
    FactoryBot.create(
      :alchemy_page,
      :public,
      :layoutpage,
      urlname: nil,
      title: "Footer"
    )
  end

  describe "GET /alchemy/json_api/layout_pages/:id" do
    it "gets a valid JSON:API document" do
      get alchemy_json_api.layout_page_path(page)
      expect(response).to have_http_status(200)
      document = JSON.parse(response.body)
      expect(document["data"]).to have_id(page.id.to_s)
      expect(document["data"]).to have_type("page")
    end

    context "when requesting a content page" do
      let(:page) { FactoryBot.create(:alchemy_page, :public) }
      let!(:element) { FactoryBot.create(:alchemy_element, page_version: page.public_version, name: "article", autogenerate_ingredients: true) }

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
      let!(:language) { Alchemy::Language.first || FactoryBot.create(:alchemy_language) }
      let!(:other_language) { FactoryBot.create(:alchemy_language, :german) }
      let(:page) { FactoryBot.create(:alchemy_page, :public, :layoutpage, language: other_language) }

      it "returns a 404" do
        get alchemy_json_api.layout_page_path(page.urlname)
        expect(response).to have_http_status(404)
      end
    end

    context "when requesting an unpublished layout page" do
      let(:page) { FactoryBot.create(:alchemy_page, :layoutpage) }

      context "for normal users" do
        it "does not find the page" do
          get alchemy_json_api.layout_page_path(page.urlname)
          expect(response).to have_http_status(404)
        end
      end

      context "for author users" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user) do
            FactoryBot.create(:alchemy_author_user)
          end
        end

        it "does not find the page" do
          get alchemy_json_api.layout_page_path(page.urlname)
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "GET /alchemy/json_api/layout_pages/:page_layout" do
    let(:page) do
      FactoryBot.create(:alchemy_page, :public, :layoutpage, name: "My Footer")
    end

    it "finds the page by its page layout" do
      get alchemy_json_api.layout_page_path(page.page_layout)
      expect(response).to have_http_status(200)
      document = JSON.parse(response.body)
      expect(document["data"]).to have_id(page.id.to_s)
      expect(document["data"]).to have_type("page")
    end

    it "includes the public elements" do
      element = FactoryBot.create(:alchemy_element, page_version: page.public_version)
      get alchemy_json_api.layout_page_path(page.page_layout)
      document = JSON.parse(response.body)
      expect(document["data"]["relationships"]["elements"]["data"]).to eq(
        [{"id" => element.id.to_s, "type" => "element"}]
      )
    end

    context "when another layout page has the page layout as urlname" do
      let!(:other_page) do
        FactoryBot.create(:alchemy_page, :public, :layoutpage, page_layout: "erb_layout", name: page.page_layout)
      end

      it "prefers the urlname" do
        expect(other_page.urlname).to eq(page.page_layout)
        get alchemy_json_api.layout_page_path(page.page_layout)
        document = JSON.parse(response.body)
        expect(document["data"]).to have_id(other_page.id.to_s)
      end
    end

    context "when a content page has the page layout" do
      let!(:content_page) { FactoryBot.create(:alchemy_page, :public, page_layout: "standard") }

      it "returns a 404" do
        get alchemy_json_api.layout_page_path("standard")
        expect(response).to have_http_status(404)
      end
    end

    context "when the layout page is not published" do
      let(:page) { FactoryBot.create(:alchemy_page, :layoutpage) }

      it "returns a 404" do
        get alchemy_json_api.layout_page_path(page.page_layout)
        expect(response).to have_http_status(404)
      end
    end

    context "with caching enabled" do
      before do
        allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
        stub_alchemy_config(cache_pages: true)
      end

      it "returns not modified if browser sends fresh cache headers" do
        get alchemy_json_api.layout_page_path(page.page_layout)
        etag = response.headers["ETag"]
        expect(etag).to be_present
        get alchemy_json_api.layout_page_path(page.page_layout),
          headers: {"If-None-Match" => etag}
        expect(response.status).to eq(304)
      end
    end
  end

  describe "GET /alchemy/json_api/layout_pages" do
    context "with contentpages and unpublished layout pages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
      let!(:non_public_layout_page) { FactoryBot.create(:alchemy_page, :layoutpage) }
      let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

      context "for normal users" do
        it "returns all public layout pages" do
          get alchemy_json_api.layout_pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).not_to include(have_id(non_public_layout_page.id.to_s))
          expect(document["data"]).not_to include(have_id(public_page.id.to_s))
        end
      end

      context "for author users" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user) do
            FactoryBot.create(:alchemy_author_user)
          end
        end

        it "returns all published layout pages" do
          get alchemy_json_api.layout_pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).not_to include(have_id(non_public_layout_page.id.to_s))
          expect(document["data"]).not_to include(have_id(public_page.id.to_s))
        end
      end
    end

    context "with pagination params" do
      before do
        FactoryBot.create_list(:alchemy_page, 3, :layoutpage, :public)
      end

      it "returns paginated result" do
        get alchemy_json_api.layout_pages_path(page: {number: 2, size: 1})
        document = JSON.parse(response.body)
        expect(document["data"].length).to eq(1)
        expect(document["meta"]).to eq({
          "pagination" => {
            "current" => 2,
            "first" => 1,
            "last" => 3,
            "next" => 3,
            "prev" => 1,
            "records" => 3
          },
          "total" => 3
        })
      end
    end
  end
end
