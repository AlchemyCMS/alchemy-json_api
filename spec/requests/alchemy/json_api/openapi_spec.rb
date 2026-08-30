# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::JsonApi::Openapi", type: :request do
  describe "GET /alchemy/json_api/openapi" do
    it "returns the OpenAPI spec as JSON" do
      get alchemy_json_api.openapi_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/json")

      document = JSON.parse(response.body)
      expect(document["openapi"]).to start_with("3.0")
      expect(document["info"]["title"]).to eq("Alchemy CMS JSON API")
      expect(document["paths"]).to include("/pages", "/pages/{path}", "/nodes")
    end
  end

  describe "GET /alchemy/json_api/docs" do
    context "in development environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        Rails.application.reload_routes!
      end

      it "returns an HTML page with Swagger UI in development", :aggregate_failures do
        get alchemy_json_api.docs_path

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/html")
        expect(response.body).to include("swagger-ui")
        expect(response.body).to include(alchemy_json_api.openapi_path)
      end

      after do
        allow(Rails).to receive(:env).and_call_original
        Rails.application.reload_routes!
      end
    end

    it "is not routable in non-development environments" do
      get alchemy_json_api.docs_path
      expect(response).to have_http_status(:not_found)
    end
  end
end
