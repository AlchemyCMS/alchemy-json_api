# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page Routing" do
  routes { Alchemy::JsonApi::Engine.routes }

  it "routes pages/" do
    expect(get: "/pages").to route_to(
      controller: "alchemy/json_api/pages",
      action: "index"
    )
  end

  it "routes pages/:id" do
    expect(get: "/pages/1").to route_to(
      controller: "alchemy/json_api/pages",
      action: "show",
      path: "1"
    )
  end

  it "routes pages/:urlname" do
    expect(get: "/pages/a-page").to route_to(
      controller: "alchemy/json_api/pages",
      action: "show",
      path: "a-page"
    )
  end

  it "routes pages/:nested/urlname" do
    expect(get: "/pages/a-nested/page").to route_to(
      controller: "alchemy/json_api/pages",
      action: "show",
      path: "a-nested/page"
    )
  end
end
