RSpec.shared_examples "an essence" do
  describe 'attributes' do
    subject { serializer.serializable_hash[:data][:attributes] }

    it 'has the right keys and values' do
      expect(subject[:created_at]).to eq(essence.created_at)
      expect(subject[:updated_at]).to eq(essence.updated_at)
    end
  end

  describe 'relationships' do
    subject { serializer.serializable_hash[:data][:relationships] }

    it 'has the right keys and values' do
      expect(subject[:content]).to eq(data: {id: content.id.to_s, type: :content})
    end
  end
end
