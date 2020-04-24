require 'rails_helper'
require 'alchemy/test_support/factories'

RSpec.describe Alchemy::JsonApi::PageSerializer do
  let(:page) { FactoryBot.build(:alchemy_page, urlname: 'a-page') }
  let(:options) { {} }

  subject(:serializer) { described_class.new(page, options) }

  describe '#to_serializable_hash' do
    subject { serializer.serializable_hash }

    it 'has the right keys and values' do
      attributes = subject[:data][:attributes]
      expect(attributes[:urlname]).to eq(page.urlname)
    end
  end
end
