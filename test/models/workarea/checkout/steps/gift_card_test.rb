require 'test_helper'

module Workarea
  class Checkout
    module Steps
      class GiftCardTest < TestCase
        setup :setup_checkout

        def setup_checkout
          create_shipping_service(name: 'Ground', rates: [{ price: 7.to_m }])

          product = create_product(
            name: 'Integration Product',
            variants: [{ sku: 'SKU1', regular: 5.to_m }]
          )

          @order = create_order.tap do |order|
            order.add_item(
              product_id: product.id,
              sku: product.skus.first,
              quantity: 2
            )
          end

          @checkout = Checkout.new(@order)
          @checkout.update(
            email: 'test@workarea.com',
            billing_address: factory_defaults(:billing_address),
            shipping_address: factory_defaults(:shipping_address),
            shipping_service: 'Ground'
          )

          @payment = @checkout.payment
        end

        def test_update
          card_one = create_gift_card(amount: 10.to_m)
          card_two = create_gift_card(amount: 20.to_m)

          step = Checkout::Steps::GiftCard.new(@checkout)
          assert(step.update(gift_card_number: " #{card_one.number}  "))

          @payment.reload
          assert_equal(1, @payment.gift_cards.count)

          tender = @payment.gift_cards.first
          assert_equal(card_one.token, tender.number)
          assert_equal(10.to_m, tender.amount)

          @order.reload
          assert_equal(17.to_m, @order.total_price)

          step = Checkout::Steps::GiftCard.new(@checkout)
          assert(step.update(gift_card_number: card_two.number))

          @payment.reload
          assert_equal(2, @payment.gift_cards.count)

          tender = @payment.gift_cards.first
          assert_equal(card_one.token, tender.number)
          assert_equal(10.to_m, tender.amount)

          tender = @payment.gift_cards.last
          assert_equal(card_two.token, tender.number)
          assert_equal(7.to_m, tender.amount)
        end

        def test_remove
          card_one = create_gift_card(amount: 10.to_m)
          card_two = create_gift_card(amount: 20.to_m)

          step = Checkout::Steps::GiftCard.new(@checkout)
          step.update(gift_card_number: card_one.token)
          step.update(gift_card_number: card_two.token)

          assert_equal(2, @payment.reload.gift_cards.count)
          assert_equal(10.to_m, @payment.gift_cards.first.amount)
          assert_equal(7.to_m, @payment.gift_cards.last.amount)

          step.remove(@payment.gift_cards.first)
          assert_equal(1, @payment.reload.gift_cards.count)
          assert_equal(card_two.token, @payment.gift_cards.first.number)
          assert_equal(17.to_m, @payment.gift_cards.first.amount)
        end

        def test_complete?
          card = create_gift_card(amount: 10.to_m)
          step = Checkout::Steps::GiftCard.new(@checkout)

          assert(step.complete?)

          @payment.add_gift_card(number: card.number)
          assert(step.complete?)

          @payment.add_gift_card(number: '')
          refute(step.complete?)

          @payment.reload.add_gift_card(number: '1234')
          refute(step.complete?)
        end
      end
    end
  end
end
