# frozen_string_literal: true
require "rails_helper"
require "alchemy/test_support/factories/page_factory"
require "alchemy/test_support/factories/element_factory"
require "alchemy/devise/test_support/factories"

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

    context "when requesting a nested URL" do
      let(:page) do
        FactoryBot.create(
          :alchemy_page,
          :public,
          urlname: "a-nested/page",
        )
      end

      it "finds the page" do
        get alchemy_json_api.page_path(page.urlname)
        expect(response).to have_http_status(200)
      end
    end

    context "when the language is incorrect" do
      let!(:language) { FactoryBot.create(:alchemy_language) }
      let!(:other_language) { FactoryBot.create(:alchemy_language, :german) }
      let(:page) { FactoryBot.create(:alchemy_page, :public, language: other_language) }

      it "returns a 404" do
        get alchemy_json_api.page_path(page.urlname)
        expect(response).to have_http_status(404)
      end
    end

    context "when requesting an unpublished page" do
      let(:page) { FactoryBot.create(:alchemy_page) }

      context "as anonymous user" do
        it "returns a 404" do
          get alchemy_json_api.page_path(page.urlname)
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
          get alchemy_json_api.page_path(page.urlname)
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe "GET /alchemy/json_api/pages" do
    context "with layoutpages and unpublished pages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
      let!(:non_public_page) { FactoryBot.create(:alchemy_page) }
      let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

      context "as anonymous user" do
        it "returns public content pages only" do
          get alchemy_json_api.pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).not_to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).not_to include(have_id(non_public_page.id.to_s))
          expect(document["data"]).to include(have_id(public_page.id.to_s))
        end
      end

      context "as admin user" do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user) do
            FactoryBot.create(:alchemy_admin_user)
          end
        end

        it "returns all content pages" do
          get alchemy_json_api.pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).not_to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).to include(have_id(non_public_page.id.to_s))
          expect(document["data"]).to include(have_id(public_page.id.to_s))
        end
      end
    end

    context "with pagination params" do
      before do
        FactoryBot.create_list(:alchemy_page, 3, :public)
      end

      it "returns paginated result" do
        get alchemy_json_api.pages_path(page: { number: 2, size: 1 })
        document = JSON.parse(response.body)
        expect(document["data"].length).to eq(1)
        expect(document["meta"]).to eq({
          "pagination" => {
            "current" => 2,
            "first" => 1,
            "last" => 4,
            "next" => 3,
            "prev" => 1,
          },
          "total" => 4,
        })
      end
    end
  end
end
