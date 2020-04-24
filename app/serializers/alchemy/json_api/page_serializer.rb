module Alchemy
  module JsonApi
    class PageSerializer
      include FastJsonapi::ObjectSerializer
      attributes :urlname
    end
  end
end
