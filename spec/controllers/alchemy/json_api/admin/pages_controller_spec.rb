# frozen_string_literal: true

require "rails_helper"
require "alchemy/devise/test_support/factories"
require "alchemy/test_support/integration_helpers"

RSpec.describe Alchemy::JsonApi::Admin::PagesController do
  include Devise::Test::ControllerHelpers
  include Alchemy::TestSupport::IntegrationHelpers

  routes { Alchemy::JsonApi::Engine.routes }

  before { authorize_user(FactoryBot.build(:alchemy_author_user)) }

  describe "#show" do
    let(:page) { FactoryBot.create(:alchemy_page) }

    it "stores page as preview" do
      get :show, params: {path: page.urlname}
      expect(Alchemy::Current.preview_page).to eq(page)
    end

    context "with alchemy_preview_time param" do
      it "stores preview time" do
        preview_time = 1.day.from_now
        get :show, params: {path: page.urlname, alchemy_preview_time: preview_time.iso8601}
        expect(Alchemy::Current.preview_time).to be_within(1.second).of(preview_time)
      end
    end

    it "runs action in given timezone" do
      allow(Time).to receive(:use_zone).and_yield
      get :show, params: {path: page.urlname, admin_timezone: "Hawaii"}
      expect(Time).to have_received(:use_zone).with("Hawaii")
    end
  end
end
