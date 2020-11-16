# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories/page_factory"
require "alchemy/test_support/factories/element_factory"
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

    context "when requesting an unpublished layout page" do
      let(:page) { FactoryBot.create(:alchemy_page, :layoutpage) }

      context "as anonymous user" do
        it "returns a 404" do
          get alchemy_json_api.layout_page_path(page.urlname)
          expect(response).to have_http_status(404)
        end
      end

      context "as admin" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user) do
            FactoryBot.create(:alchemy_admin_user)
          end
        end

        it "finds the page" do
          get alchemy_json_api.layout_page_path(page.urlname)
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "GET /alchemy/json_api/layout_pages" do
    context "with contentpages and unpublished layout pages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
      let!(:non_public_layout_page) { FactoryBot.create(:alchemy_page, :layoutpage) }
      let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

      context "as anonymous user" do
        it "returns only public layout pages" do
          get alchemy_json_api.layout_pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).not_to include(have_id(non_public_layout_page.id.to_s))
          expect(document["data"]).not_to include(have_id(public_page.id.to_s))
        end
      end

      context "as admin user" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user) do
            FactoryBot.create(:alchemy_admin_user)
          end
        end

        it "returns all layout pages" do
          get alchemy_json_api.layout_pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).to include(have_id(non_public_layout_page.id.to_s))
          expect(document["data"]).not_to include(have_id(public_page.id.to_s))
        end
      end
    end

    context "with pagination params" do
      before do
        FactoryBot.create_list(:alchemy_page, 3, :layoutpage, :public)
      end

      it "returns paginated result" do
        get alchemy_json_api.layout_pages_path(page: { number: 2, size: 1 })
        document = JSON.parse(response.body)
        expect(document["data"].length).to eq(1)
        expect(document["meta"]).to eq({
          "pagination" => {
            "current" => 2,
            "first" => 1,
            "last" => 3,
            "next" => 3,
            "prev" => 1,
          },
          "total" => 3,
        })
      end
    end
  end
end
