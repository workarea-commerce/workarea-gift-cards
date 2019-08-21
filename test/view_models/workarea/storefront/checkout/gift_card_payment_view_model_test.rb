require 'test_helper'

module Workarea
  module Storefront
    module Checkout
      class GiftCardPaymentViewModelTest < TestCase
        def test_order_covered_by_gift_card_when_amounts_match
          product = create_product
          order = create_order
          order.add_item(sku: product.skus.first, quantity: 1, product_id: product.id)
          Pricing.perform(order)
          order.reload
          gift_card = create_gift_card(amount: order.total_price, token: 'foo')
          payment = create_payment(id: order.id)
          payment.set_gift_card(number: gift_card.token)
          checkout = Workarea::Checkout.new(order)
          step = Workarea::Checkout::Steps::Payment.new(checkout)
          step.update(gift_card: { number: gift_card.token })
          view_model = Storefront::Checkout::PaymentViewModel.new(step)

          assert(view_model.show_gift_card?)
          assert(view_model.order_covered_by_gift_card?)
        end

        def test_order_covered_by_gift_card_when_balance_exceeds_total
          product = create_product
          order = create_order
          order.add_item(sku: product.skus.first, quantity: 1, product_id: product.id)
          Pricing.perform(order)
          order.reload
          gift_card = create_gift_card(amount: order.total_price + 1.to_m, token: 'foo')
          payment = create_payment(id: order.id)
          payment.set_gift_card(number: gift_card.token)
          checkout = Workarea::Checkout.new(order)
          step = Workarea::Checkout::Steps::Payment.new(checkout)
          step.update(gift_card: { number: gift_card.token })
          view_model = Storefront::Checkout::PaymentViewModel.new(step)

          assert(view_model.show_gift_card?)
          assert(view_model.order_covered_by_gift_card?)
        end

        def test_order_not_covered_by_gift_card_when_total_exceeds_balance
          product = create_product
          order = create_order
          order.add_item(sku: product.skus.first, quantity: 1, product_id: product.id)
          Pricing.perform(order)
          order.reload
          gift_card = create_gift_card(amount: 1.to_m, token: 'foo')
          payment = create_payment(id: order.id)
          payment.set_gift_card(number: gift_card.token)
          checkout = Workarea::Checkout.new(order)
          step = Workarea::Checkout::Steps::Payment.new(checkout)
          step.update(gift_card: { number: gift_card.token })
          view_model = Storefront::Checkout::PaymentViewModel.new(step)

          assert(view_model.show_gift_card?)
          assert_equal(5.to_m, order.total_price)
          assert_equal(1.to_m, view_model.gift_card_balance)
          refute(view_model.order_covered_by_gift_card?)
        end
      end
    end
  end
end
