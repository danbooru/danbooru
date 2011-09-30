module Downloads
  module Strategies
    class Base
      def self.strategies
        [Pixiv, Tinami, Pixa]
      end
      
      def rewrite(url, headers)
        return [url, headers]
      end
    end
  end
end
