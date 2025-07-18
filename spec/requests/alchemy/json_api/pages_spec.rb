# frozen_string_literal: true

require "rails_helper"
require "alchemy/devise/test_support/factories"
require "alchemy/version"

RSpec.describe "Alchemy::JsonApi::Pages", type: :request do
  let(:page) do
    FactoryBot.create(
      :alchemy_page,
      :public,
      urlname: "a-page",
      title: "Page Title",
      meta_keywords: "Meta Keywords",
      meta_description: "Meta Description",
      tag_list: "Tag1,Tag2"
    )
  end

  around do |example|
    travel_to(published_at - 1.week) do
      example.run
    end
  end

  let(:published_at) { DateTime.parse("2024-05-04 00:00:00") }

  describe "GET /alchemy/json_api/pages/:id" do
    context "a published page" do
      let(:page) do
        FactoryBot.create(
          :alchemy_page,
          :public,
          published_at: published_at
        )
      end

      context "with caching enabled" do
        before do
          allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
          stub_alchemy_config(:cache_pages, true)
        end

        it "sets public cache headers" do
          get alchemy_json_api.page_path(page)
          first_etag = response.headers["Last-Modified"]
          expect(response.headers["ETag"]).to match(/W\/".+"/)
          expect(response.headers["Cache-Control"]).to eq("max-age=600, public, must-revalidate")
          get alchemy_json_api.page_path(page)
          expect(response.headers["Last-Modified"]).to eq(first_etag)
        end

        it "can set cache duration via config" do
          allow(Alchemy::JsonApi).to receive(:page_cache_max_age) { 60 }
          get alchemy_json_api.page_path(page)
          expect(response.headers["Cache-Control"]).to eq("max-age=60, public, must-revalidate")
        end

        it "can set stale-while-revalidate header via config" do
          allow(Alchemy::JsonApi).to receive(:page_caching_options) { {stale_while_revalidate: 60} }
          get alchemy_json_api.page_path(page)
          expect(response.headers["Cache-Control"]).to eq("max-age=600, public, stale-while-revalidate=60")
        end

        it "can set stale_if_error header via config" do
          allow(Alchemy::JsonApi).to receive(:page_caching_options) { {stale_if_error: 300} }
          get alchemy_json_api.page_path(page)
          expect(response.headers["Cache-Control"]).to eq("max-age=600, public, stale-if-error=300")
        end

        it "returns a different etag if different filters are present" do
          get alchemy_json_api.page_path(page)
          etag = response.headers["ETag"]
          get alchemy_json_api.pages_path(filter: {page_layout_eq: "standard"})
          expect(response.headers["ETag"]).not_to eq(etag)
        end

        it "returns a different etag if different include params are present" do
          get alchemy_json_api.page_path(page)
          etag = response.headers["ETag"]
          get alchemy_json_api.pages_path(include: "all_elements.ingredients")
          expect(response.headers["ETag"]).not_to eq(etag)
        end

        it "returns a different etag if different fields params are present" do
          get alchemy_json_api.page_path(page)
          etag = response.headers["ETag"]
          get alchemy_json_api.pages_path(fields: "urlname")
          expect(response.headers["ETag"]).not_to eq(etag)
        end

        context "if page is restricted" do
          let(:page) do
            FactoryBot.create(
              :alchemy_page,
              :public,
              :restricted,
              published_at: published_at
            )
          end

          it "sets private cache headers" do
            get alchemy_json_api.page_path(page)
            expect(response.headers["Cache-Control"]).to eq("max-age=600, private, must-revalidate")
          end
        end

        context "if cache for page is disabled" do
          let(:page) do
            FactoryBot.create(
              :alchemy_page,
              :public,
              page_layout: "contact",
              published_at: published_at
            )
          end

          it "sets no cache headers" do
            get alchemy_json_api.page_path(page)
            expect(response.headers["Cache-Control"]).to eq("max-age=0, private, must-revalidate")
          end
        end

        context "if browser sends fresh cache headers" do
          it "returns not modified" do
            get alchemy_json_api.page_path(page)
            etag = response.headers["ETag"]
            get alchemy_json_api.page_path(page),
              headers: {
                "If-Modified-Since" => page.published_at.utc.httpdate,
                "If-None-Match" => etag
              }
            expect(response.status).to eq(304)
          end
        end
      end
    end

    it "gets a valid JSON:API document" do
      get alchemy_json_api.page_path(page)
      expect(response).to have_http_status(200)
      document = JSON.parse(response.body)
      expect(document["data"]).to have_id(page.id.to_s)
      expect(document["data"]).to have_type("page")
    end

    context "when including elements and ingredients" do
      let!(:element) { FactoryBot.create(:alchemy_element, page_version: page.public_version, name: "article", autogenerate_ingredients: true) }
      let!(:nested_element) { FactoryBot.create(:alchemy_element, page_version: page.public_version, name: "article", parent_element: element) }

      it "includes the data" do
        get alchemy_json_api.page_path(page, include: "all_elements.ingredients")
        included = JSON.parse(response.body)["included"]
        expect(included).to include(have_type("element").and(have_id(element.id.to_s)))
        expect(included).to include(have_type("element").and(have_id(nested_element.id.to_s)))
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
          urlname: "a-nested/page"
        )
      end

      it "finds the page" do
        get alchemy_json_api.page_path(page.urlname)
        expect(response).to have_http_status(200)
      end
    end

    context "when the language is incorrect" do
      let!(:language) { Alchemy::Language.first || FactoryBot.create(:alchemy_language) }
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

        it "does not find the page" do
          get alchemy_json_api.page_path(page.urlname)
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "GET /alchemy/json_api/pages" do
    context "with layoutpages and unpublished pages" do
      let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public, page_layout: "standard") }
      let!(:non_public_page) { FactoryBot.create(:alchemy_page, page_layout: "standard") }
      let!(:public_page) { FactoryBot.create(:alchemy_page, :public, published_at: published_at, page_layout: "standard") }

      context "as anonymous user" do
        let!(:pages) { [public_page] }

        context "with caching enabled" do
          before do
            allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
            stub_alchemy_config(:cache_pages, true)
          end

          it "sets public cache headers of latest published page" do
            get alchemy_json_api.pages_path
            expect(response.headers["Last-Modified"]).to be_nil
            expect(response.headers["ETag"]).to match(/W\/".+"/)
            expect(response.headers["Cache-Control"]).to eq("max-age=600, public, must-revalidate")
          end

          it "returns a different etag if different filters are present" do
            get alchemy_json_api.pages_path
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(filter: {page_layout_eq: "standard"})
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          it "returns a different etag if different sort params are present" do
            get alchemy_json_api.pages_path
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(sort: "-id")
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          it "returns a different etag if different include params are present" do
            get alchemy_json_api.pages_path
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(include: "all_elements.ingredients")
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          it "returns a different etag if different fields params are present" do
            get alchemy_json_api.pages_path
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(fields: "urlname")
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          it "returns a different etag if different fields params are present" do
            get alchemy_json_api.pages_path
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(page: {number: 2, size: 1})
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          it "returns a different etag if different JSONAPI params have the same value" do
            get alchemy_json_api.pages_path(sort: "author")
            etag = response.headers["ETag"]
            get alchemy_json_api.pages_path(fields: "author")
            expect(response.headers["ETag"]).not_to eq(etag)
          end

          context "if one page is restricted" do
            let!(:restricted_page) do
              FactoryBot.create(
                :alchemy_page,
                :public,
                :restricted,
                published_at: published_at
              )
            end

            it "sets private cache headers" do
              get alchemy_json_api.pages_path
              expect(response.headers["Cache-Control"]).to eq("max-age=600, private, must-revalidate")
            end
          end

          context "if for one page caching is disabled" do
            let!(:no_cache_page) do
              FactoryBot.create(
                :alchemy_page,
                :public,
                page_layout: "contact",
                published_at: published_at
              )
            end

            it "sends no cache headers" do
              get alchemy_json_api.pages_path
              expect(response.headers["Cache-Control"]).to eq("max-age=0, private, must-revalidate")
            end
          end

          context "if browser sends fresh cache headers" do
            it "returns not modified" do
              get alchemy_json_api.pages_path
              etag = response.headers["ETag"]
              get alchemy_json_api.pages_path,
                headers: {
                  "If-Modified-Since" => pages.max_by(&:published_at).published_at.utc.httpdate,
                  "If-None-Match" => etag
                }
              expect(response.status).to eq(304)
            end
          end
        end

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

        it "returns all published content pages" do
          get alchemy_json_api.pages_path
          document = JSON.parse(response.body)
          expect(document["data"]).not_to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).not_to include(have_id(non_public_page.id.to_s))
          expect(document["data"]).to include(have_id(public_page.id.to_s))
        end
      end
    end

    context "with filters" do
      let!(:standard_page) { FactoryBot.create(:alchemy_page, :public, published_at: 2.weeks.ago) }
      let!(:news_page) { FactoryBot.create(:alchemy_page, :public, page_layout: "news", published_at: 1.week.ago) }
      let!(:news_page2) { FactoryBot.create(:alchemy_page, :public, name: "News", page_layout: "news", published_at: published_at) }

      it "returns only matching pages by page_layout" do
        get alchemy_json_api.pages_path(filter: {page_layout_eq: "news"})
        document = JSON.parse(response.body)
        expect(document["data"]).not_to include(have_id(standard_page.id.to_s))
        expect(document["data"]).to include(have_id(news_page.id.to_s))
        expect(document["data"]).to include(have_id(news_page2.id.to_s))
      end

      it "returns only matching pages by name" do
        get alchemy_json_api.pages_path(filter: {name_eq: "News"})
        document = JSON.parse(response.body)
        expect(document["data"]).not_to include(have_id(standard_page.id.to_s))
        expect(document["data"]).not_to include(have_id(news_page.id.to_s))
        expect(document["data"]).to include(have_id(news_page2.id.to_s))
      end

      context "if no pages returned for filter params" do
        it "does not throw error" do
          get alchemy_json_api.pages_path(filter: {page_layout_eq: "not-found"})
          expect(response).to be_successful
        end
      end

      context "with caching enabled" do
        before do
          allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
          stub_alchemy_config(:cache_pages, true)
        end

        it "sets constant etag" do
          get alchemy_json_api.pages_path(filter: {page_layout_eq: "news"})
          expect(response.headers["ETag"]).to match(/W\/".+"/)

          first_etag = response.headers["Last-Modified"]

          expect(response.headers["Cache-Control"]).to eq("max-age=600, public, must-revalidate")

          get alchemy_json_api.pages_path(filter: {page_layout_eq: "news"})
          expect(response.headers["Last-Modified"]).to eq(first_etag)
        end
      end
    end

    context "with pagination params" do
      before do
        FactoryBot.create_list(:alchemy_page, 3, :public)
      end

      it "returns paginated result" do
        get alchemy_json_api.pages_path(page: {number: 2, size: 1})
        document = JSON.parse(response.body)
        expect(document["data"].length).to eq(1)
        expect(document["meta"]).to eq({
          "pagination" => {
            "current" => 2,
            "first" => 1,
            "last" => 4,
            "next" => 3,
            "prev" => 1,
            "records" => 4
          },
          "total" => 4
        })
      end
    end
  end
end
