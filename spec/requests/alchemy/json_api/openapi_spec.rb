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
    it "returns an HTML page with Swagger UI" do
      get alchemy_json_api.docs_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/html")
      expect(response.body).to include("swagger-ui")
      expect(response.body).to include("openapi.json")
    end
  end
end
