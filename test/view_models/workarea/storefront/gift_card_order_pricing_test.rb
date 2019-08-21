require 'test_helper'

module Workarea
  module Storefront
    class GiftCardOrderPricingTest < TestCase
      class TestViewModel < ApplicationViewModel
        include OrderPricing
        include GiftCardOrderPricing

        alias_method :order, :model

        def payment
          @payment ||= options[:payment]
        end
      end

      setup :payment, :setup_gift_cards

      def order
        @order ||= create_order(total_price: 50.to_m)
      end

      def payment
        @payment ||= create_payment(id: order.id)
      end

      def setup_gift_cards
        Workarea.config.max_gift_cards_per_order = 5

        create_gift_card(token: '123', amount: 10.to_m)
        create_gift_card(token: '456', amount: 20.to_m)
        create_gift_card(token: '789', amount: 30.to_m)
      end

      def view_model_instance
        TestViewModel.new(order, payment: payment)
      end

      def test_gift_cards
        assert(view_model_instance.gift_cards.blank?)

        payment.gift_cards.build(number: '123')
        assert(view_model_instance.gift_cards.blank?)

        payment.reload
        payment.add_gift_card(number: '123')
        assert_equal(1, view_model_instance.gift_cards.count)
        assert_equal('123', view_model_instance.gift_cards.first.number)
      end

      def test_gift_card?
        refute(view_model_instance.gift_card?)

        payment.add_gift_card(number: '123')
        assert(view_model_instance.gift_card?)
      end

      def test_gift_card_amount
        assert_equal(0.to_m, view_model_instance.gift_card_amount)

        payment.add_gift_card(number: '123', amount: 10.to_m)
        assert_equal(10.to_m, view_model_instance.gift_card_amount)

        payment.add_gift_card(number: '456', amount: 5.to_m)
        assert_equal(15.to_m, view_model_instance.gift_card_amount)
      end

      def test_gift_card_balance
        assert_equal(0.to_m, view_model_instance.gift_card_balance)

        payment.add_gift_card(number: '123')
        assert_equal(10.to_m, view_model_instance.gift_card_balance)

        payment.add_gift_card(number: '456')
        assert_equal(30.to_m, view_model_instance.gift_card_balance)
      end

      def test_total_before_gift_cards
        assert_equal(50.to_m, view_model_instance.total_before_gift_cards)

        payment.add_gift_card(number: '123', amount: 10.to_m)
        assert_equal(50.to_m, view_model_instance.total_before_gift_cards)

        payment.add_gift_card(number: '456', amount: 20.to_m)
        assert_equal(50.to_m, view_model_instance.total_before_gift_cards)
      end

      def test_advance_payment_amount
        assert_equal(0.to_m, view_model_instance.advance_payment_amount)

        payment.add_gift_card(number: '123', amount: 10.to_m)
        assert_equal(10.to_m, view_model_instance.advance_payment_amount)

        payment.add_gift_card(number: '456', amount: 20.to_m)
        assert_equal(30.to_m, view_model_instance.advance_payment_amount)

        payment.add_gift_card(number: '789', amount: 20.to_m)
        assert_equal(50.to_m, view_model_instance.advance_payment_amount)
      end

      def test_failed_gift_card
        assert_nil(view_model_instance.failed_gift_card)

        payment.add_gift_card(number: '123')
        assert_nil(view_model_instance.failed_gift_card)

        Workarea.config.max_gift_cards_per_order = 1
        payment.add_gift_card(number: '456')
        assert_equal('456', view_model_instance.failed_gift_card.number)
      end
    end
  end
end
