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
      if Alchemy.const_defined?(:Current)
        expect(Alchemy::Current.preview_page).to eq(page)
      else
        expect(Alchemy::Page.current_preview).to eq(page.id)
      end
    end
  end
end
