require "rails_helper"

RSpec.describe Alchemy::Page, type: :model do
  describe ".ransackable_attributes" do
    let(:auth_object) { double }

    subject { described_class.ransackable_attributes(auth_object) }

    it { is_expected.to include("page_layout") }
  end
end
