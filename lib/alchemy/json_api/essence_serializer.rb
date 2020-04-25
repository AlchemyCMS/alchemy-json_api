module Alchemy
  module JsonApi
    module EssenceSerializer
      def self.included(klass)
        klass.include FastJsonapi::ObjectSerializer
        klass.has_one :content
        klass.attributes :created_at, :updated_at
      end
    end
  end
end
