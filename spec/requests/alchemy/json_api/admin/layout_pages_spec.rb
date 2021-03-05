# frozen_string_literal: true
require "rails_helper"
require "alchemy/devise/test_support/factories"

RSpec.describe "Alchemy::JsonApi::Admin::LayoutPagesController", type: :request do
  let(:page) do
    FactoryBot.create(:alchemy_page, :layoutpage)
  end

  describe "GET /alchemy/json_api/admin/layout_pages" do
    subject { get alchemy_json_api.admin_layout_pages_path }

    context "as anonymous user" do
      it "returns 401" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "as author user" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user) do
          FactoryBot.create(:alchemy_author_user)
        end
      end

      context "with contentpages and unpublished layout pages" do
        let!(:layoutpage) { FactoryBot.create(:alchemy_page, :layoutpage, :public) }
        let!(:non_public_layout_page) { FactoryBot.create(:alchemy_page, :layoutpage) }
        let!(:public_page) { FactoryBot.create(:alchemy_page, :public) }

        it "returns all layout pages" do
          subject
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(layoutpage.id.to_s))
          expect(document["data"]).to include(have_id(non_public_layout_page.id.to_s))
          expect(document["data"]).not_to include(have_id(public_page.id.to_s))
        end
      end

      context "with pagination params" do
        before do
          FactoryBot.create_list(:alchemy_page, 3, :layoutpage, :public)
        end

        it "returns paginated result" do
          get alchemy_json_api.admin_layout_pages_path(page: { number: 2, size: 1 })
          document = JSON.parse(response.body)
          expect(document["data"].length).to eq(1)
          expect(document["meta"]).to eq({
            "pagination" => {
              "current" => 2,
              "first" => 1,
              "last" => 3,
              "next" => 3,
              "prev" => 1,
              "records" => 3,
            },
            "total" => 3,
          })
        end
      end
    end
  end

  describe "GET /alchemy/json_api/admin/layout_pages/:id" do
    subject { get alchemy_json_api.admin_layout_page_path(page) }

    context "as anonymous user" do
      it "returns 401" do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context "as author user" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user) do
          FactoryBot.create(:alchemy_author_user)
        end
      end

      let(:document) { JSON.parse(response.body) }

      it "gets a valid JSON:API document" do
        subject
        expect(response).to have_http_status(200)
        expect(document["data"]).to have_id(page.id.to_s)
        expect(document["data"]).to have_type("page")
      end

      it "loads elements from draft version" do
        element = FactoryBot.create(:alchemy_element, page_version: page.draft_version)
        subject
        document = JSON.parse(response.body)
        expect(document["data"]["relationships"]["elements"]).to eq(
          {
            "data" => [{
              "id" => element.id.to_s,
              "type" => "element",
            }],
          }
        )
      end
    end
  end

  describe "GET /alchemy/json_api/admin/layout_pages/:urlpath" do
    subject { get alchemy_json_api.admin_layout_page_path(page.urlname) }

    context "as author user" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user) do
          FactoryBot.create(:alchemy_author_user)
        end
      end

      it "gets a valid JSON:API document" do
        subject
        expect(response).to have_http_status(200)
      end
    end
  end
end
