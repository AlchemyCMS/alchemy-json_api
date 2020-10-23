# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page Routing" do
  routes { Alchemy::JsonApi::Engine.routes }

  it "routes layout_pages/" do
    expect(get: "/layout_pages").to route_to(
      controller: "alchemy/json_api/layout_pages",
      action: "index",
    )
  end

  it "routes layout_pages/:id" do
    expect(get: "/layout_pages/1").to route_to(
      controller: "alchemy/json_api/layout_pages",
      action: "show",
      path: "1",
    )
  end

  it "routes layout_pages/:urlname" do
    expect(get: "/layout_pages/a-page").to route_to(
      controller: "alchemy/json_api/layout_pages",
      action: "show",
      path: "a-page",
    )
  end

  it "routes layout_pages/:nested/urlname" do
    expect(get: "/layout_pages/a-nested/page").to route_to(
      controller: "alchemy/json_api/layout_pages",
      action: "show",
      path: "a-nested/page",
    )
  end
end
