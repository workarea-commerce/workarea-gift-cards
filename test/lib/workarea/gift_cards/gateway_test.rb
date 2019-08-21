require 'test_helper'

module Workarea
  module GiftCards
    class GatewayTest < TestCase
      setup :gift_card

      def gift_card
        @gift_card ||= create_gift_card(amount: 10.to_m)
      end

      def tender
        @tender ||= Payment::Tender::GiftCard.new(
          number: gift_card.token,
          amount: 5.to_m
        )
      end

      def gateway
        Gateway.new
      end

      def test_authorize
        response = gateway.authorize(200, tender)

        assert(response.success?)
        assert(response.message.present?)

        gift_card.reload
        assert_equal(8.to_m, gift_card.balance)
        assert_equal(2.to_m, gift_card.used)
      end

      def test_cancel
        response = gateway.authorize(200, tender)
        assert(response.success?)

        response = gateway.cancel(200, tender)

        assert(response.success?)
        assert(response.message.present?)

        gift_card.reload
        assert_equal(10.to_m, gift_card.balance)
        assert_equal(0.to_m, gift_card.used)
      end

      def test_capture
        assert(gateway.capture(200, tender).success?)
        assert_equal(10.to_m, gift_card.reload.balance)
      end

      def test_purchase
        response = gateway.purchase(200, tender)

        assert(response.success?)
        assert(response.message.present?)

        gift_card.reload
        assert_equal(8.to_m, gift_card.balance)
        assert_equal(2.to_m, gift_card.used)
      end

      def test_refund
        response = gateway.authorize(200, tender)
        assert(response.success?)

        response = gateway.refund(200, tender)

        assert(response.success?)
        assert(response.message.present?)

        gift_card.reload
        assert_equal(10.to_m, gift_card.balance)
        assert_equal(0.to_m, gift_card.used)
      end

      def test_balance
        balance = gateway.balance(gift_card.number)
        assert_equal(10.to_m, balance)

        gateway.authorize(300, tender)

        balance = gateway.balance(gift_card.number)
        assert_equal(7.to_m, balance)
      end

      def test_lookup
        lookup = gateway.lookup(email: gift_card.to, token: gift_card.token)
        assert_equal(gift_card.id, lookup.id)

        lookup = gateway.lookup(email: 'foo', token: gift_card.token)
        assert_nil(lookup)
      end
    end
  end
end
