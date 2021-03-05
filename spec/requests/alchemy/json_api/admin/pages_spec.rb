# frozen_string_literal: true
require "rails_helper"
require "alchemy/devise/test_support/factories"

RSpec.describe "Alchemy::JsonApi::Admin::PagesController", type: :request do
  let(:page) do
    FactoryBot.create(:alchemy_page)
  end

  describe "GET /alchemy/json_api/admin/pages/:id" do
    subject { get alchemy_json_api.admin_page_path(page) }

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

  describe "GET /alchemy/json_api/admin/pages/:urlpath" do
    subject { get alchemy_json_api.admin_page_path(page.urlname) }

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
