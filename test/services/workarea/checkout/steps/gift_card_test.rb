require 'test_helper'

module Workarea
  class Checkout
    module Steps
      class GiftCardTest < TestCase
        def user
          @user ||= create_user
        end

        def order
          @order ||= create_order
        end

        def checkout
          @checkout ||= Checkout.new(order, user)
        end

        def payment
          @payment ||= checkout.payment.tap(&:save!)
        end

        def step
          @step ||= Checkout::Steps::GiftCard.new(checkout)
        end

        def card
          @card ||= create_gift_card
        end

        def test_user
          assert_equal(user, step.user)
        end

        def test_update
          product = create_product
          create_shipping_sku(id: product.skus.first)
          shipping = create_shipping(order_id: order.id)
          shipping.set_shipping_service(
            id: 'GROUND',
            name: 'Ground',
            tax_code: '001',
            base_price: 1.to_m
          )
          shipping.set_address(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          )
          order.add_item(
            product_id: product.id,
            sku: product.skus.first,
            quantity: 1
          )
          params = { gift_card_number: " #{card.number}  " }

          refute_empty(order.items)
          assert(payment.set_gift_card(number: card.number))
          assert(step.update(params))

          assert_equal(1.to_m, order.shipping_total)
          assert_equal(5.to_m, order.subtotal_price)
          assert_equal(6.to_m, payment.gift_card.amount)
        end

        def test_complete?
          assert(step.complete?)

          payment.set_gift_card(number: card.number)
          assert(step.complete?)

          payment.set_gift_card(number: '')
          refute(step.complete?)

          payment.set_gift_card(number: '1234')
          refute(step.complete?)
        end
      end
    end
  end
end
