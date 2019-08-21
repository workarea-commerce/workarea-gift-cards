require 'test_helper'

module Workarea
  class CreateOrderedGiftCardsTest < TestCase
    def test_perform
      order = create_order(id: 123)
      order.add_item(
        product_id: 'PROD',
        sku: 'SKU',
        product_attributes: { digital: true },
        gift_card: true,
        customizations: {
          'email' => 'bob@workarea.com',
          'from' => 'system@workarea.com',
          'message' => 'Hello'
        },
        price_adjustments: [
          {
            amount: 10.to_m
          }
        ]
      )

      CreateFulfillment.new(order).perform
      CreateOrderedGiftCards.new.perform('123')
      card = Payment::GiftCard.first
      assert(card.present?)
      assert(card.notify)
      assert(card.purchased)
      assert_equal('bob@workarea.com', card.to)
      assert_equal('system@workarea.com', card.from)
      assert_equal('Hello', card.message)
      assert_equal(order.id, card.order_id)

      fulfillment = Fulfillment.find(order.id)
      assert_equal(1, fulfillment.items.first.quantity_shipped)
    end
  end
end
