require 'test_helper'

module Workarea
  class Fulfillment
    module Policies
      class CreateGiftCardTest < TestCase
        def test_process
          order = create_order
          order.add_item(
            product_id: 'PROD',
            sku: 'SKU',
            gift_card: true,
            fulfillment: 'create_gift_card',
            customizations: {
              'email' => 'bob@workarea.com',
              'from' => 'system@workarea.com',
              'message' => 'Hello'
            },
            price_adjustments: [{ amount: 10.to_m }]
          )

          fulfillment = Fulfillment.new(
            id: order.id,
            items: [{ order_item_id: order.items.first.id, quantity: 1 }]
          )

          sku = create_fulfillment_sku(id: 'SKU', policy: :create_gift_card)
          policy = CreateGiftCard.new(sku)

          policy.process(order_item: order.items.first, fulfillment: fulfillment)

          card = Payment::GiftCard.first
          assert(card.present?)
          assert(card.notify)
          assert(card.purchased)
          assert_equal('bob@workarea.com', card.to)
          assert_equal('system@workarea.com', card.from)
          assert_equal('Hello', card.message)
          assert_equal(order.id, card.order_id)
          assert_equal(10.to_m, card.amount)

          assert_equal(1, fulfillment.items.first.quantity_shipped)
        end
      end
    end
  end
end
