module Alchemy
  module JsonApi
    module EssenceSerializer
      def self.included(klass)
        klass.include FastJsonapi::ObjectSerializer
        klass.has_one :element
        klass.attributes :created_at, :updated_at
        klass.attribute :role do |essence|
          essence.content.name
        end
      end
    end
  end
end
