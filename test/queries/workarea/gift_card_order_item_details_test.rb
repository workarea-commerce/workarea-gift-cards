require 'test_helper'

module Workarea
  class GiftCardOrderItemDetailsTest < TestCase
    def test_to_hash
      product = create_product(gift_card: true)
      details = OrderItemDetails.new(product, product.skus.first)
      assert(details.to_h[:gift_card])
    end
  end
end
