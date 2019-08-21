require 'test_helper'

module Workarea
  module Catalog
    class GiftCardProductTest < TestCase
      def test_gift_card?
        product = Catalog::Product.new(template: 'gift_card')
        assert(product.gift_card?)

        product = Catalog::Product.new(gift_card: true)
        assert(product.gift_card?)
      end
    end
  end
end
