require "rails_helper"
require "alchemy/test_support/factories"

RSpec.describe Alchemy::JsonApi::EssenceDateSerializer do
  let(:content) { FactoryBot.create(:alchemy_content) }
  let(:essence) { Alchemy::EssenceDate.new(date: Date.today, content: content) }
  let(:options) { {} }

  subject(:serializer) { described_class.new(essence, options) }

  it_behaves_like "an essence"

  describe "attributes" do
    subject { serializer.serializable_hash[:data][:attributes] }

    it "has the right keys and values" do
      expect(subject[:date]).to eq(Date.today)
    end
  end
end
