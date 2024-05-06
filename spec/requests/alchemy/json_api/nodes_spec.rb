# frozen_string_literal: true

require "rails_helper"
require "alchemy/devise/test_support/factories"
require "alchemy/version"

RSpec.describe "Alchemy::JsonApi::Nodes", type: :request do
  let(:node) { FactoryBot.create(:alchemy_node, name: "A Node", page: page) }
  let(:page) { nil }

  describe "GET /alchemy/json_api/nodes" do
    let!(:nodes) { [node] }

    it "returns all nodes" do
      get alchemy_json_api.nodes_path
      document = JSON.parse(response.body)
      expect(document["data"]).to include(have_id(node.id.to_s))
    end

    context "with caching enabled" do
      before do
        allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
      end

      it "sets public cache headers of latest published node" do
        get alchemy_json_api.nodes_path
        expect(response.headers["Last-Modified"]).to eq(nodes.max_by(&:updated_at).updated_at.utc.httpdate)
        expect(response.headers["ETag"]).to match(/W\/".+"/)
        expect(response.headers["Cache-Control"]).to eq("max-age=10800, public, must-revalidate")
      end

      context "if browser sends fresh cache headers" do
        it "returns not modified" do
          get alchemy_json_api.nodes_path
          etag = response.headers["ETag"]
          get alchemy_json_api.nodes_path,
            headers: {
              "If-Modified-Since" => nodes.max_by(&:updated_at).updated_at.utc.httpdate,
              "If-None-Match" => etag
            }
          expect(response.status).to eq(304)
        end
      end
    end

    context "with page assigned" do
      let(:page) { FactoryBot.create(:alchemy_page) }

      context "with include param set to 'page'" do
        it "includes page" do
          get alchemy_json_api.nodes_path(include: "page")
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(node.id.to_s))
          expect(document["included"]).to include(have_type("page"))
          expect(document["included"]).to_not include(have_type("element"))
        end
      end

      context "with include param set to 'page.elements'" do
        let(:page) { FactoryBot.create(:alchemy_page, :public, autogenerate_elements: true) }

        it "includes page and elements" do
          get alchemy_json_api.nodes_path(include: "page.elements")
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(node.id.to_s))
          expect(document["included"]).to include(have_type("page"))
          expect(document["included"]).to include(have_type("element"))
        end
      end

      context "with include param set to 'page.all_elements.ingredients'" do
        let(:page) { FactoryBot.create(:alchemy_page, :public, autogenerate_elements: true) }

        it "includes page and elements" do
          get alchemy_json_api.nodes_path(include: "page.all_elements.ingredients")
          document = JSON.parse(response.body)
          expect(document["data"]).to include(have_id(node.id.to_s))
          expect(document["included"]).to include(have_type("page"))
          expect(document["included"]).to include(have_type("element"))
        end
      end
    end

    context "with pagination params" do
      before do
        FactoryBot.create_list(:alchemy_node, 3)
      end

      it "returns paginated result" do
        get alchemy_json_api.nodes_path(page: {number: 2, size: 1})
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
