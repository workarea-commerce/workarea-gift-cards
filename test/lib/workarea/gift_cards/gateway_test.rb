require 'test_helper'

module Workarea
  module GiftCards
    class GatewayTest < TestCase
      setup :gift_card

      # Override this to instantiate an object that models a gift card
      # on the remote system.
      def gift_card
        @gift_card ||= create_gift_card(amount: 10.to_m)
      end

      # The tender object used on an order that will be passed into each
      # gateway method call. Override this to provide your own
      # information.
      #
      # @return [Payment::Tender::GiftCard]
      def tender
        @tender ||= Payment::Tender::GiftCard.new(
          number: gift_card.token,
          amount: 5.to_m
        )
      end

      # Override this in your test to instantiate a gateway for use in
      # tests. The class name of the gateway is used to generate the
      # folder name for the VCR cassettes used within this test.
      def gateway
        Gateway.new
      end

      # Use the class name of the gateway to generate a directory in
      # `test/vcr_cassettes` where all cassettes for the custom gateway
      # will go. This doesn't need to be overridden unless you need to
      # customize the gateway cassette directory name.
      #
      # @return [String]
      def gateway_cassette_name
        gateway.class.name.systemize
      end

      def test_authorize
        VCR.use_cassette "#{gateway_cassette_name}/authorize" do
          response = gateway.authorize(200, tender)

          assert(response.success?)
          assert(response.message.present?)

          gift_card.reload
          assert_equal(8.to_m, gift_card.balance)
          assert_equal(2.to_m, gift_card.used)
        end
      end

      def test_cancel
        VCR.use_cassette "#{gateway_cassette_name}/cancel" do
          response = gateway.authorize(200, tender)
          assert(response.success?)

          response = gateway.cancel(200, tender)

          assert(response.success?)
          assert(response.message.present?)

          gift_card.reload
          assert_equal(10.to_m, gift_card.balance)
          assert_equal(0.to_m, gift_card.used)
        end
      end

      def test_capture
        VCR.use_cassette "#{gateway_cassette_name}/capture" do
          assert(gateway.capture(200, tender).success?)
          assert_equal(10.to_m, gift_card.reload.balance)
        end
      end

      def test_purchase
        VCR.use_cassette "#{gateway_cassette_name}/purchase" do
          response = gateway.purchase(200, tender)

          assert(response.success?)
          assert(response.message.present?)

          gift_card.reload
          assert_equal(8.to_m, gift_card.balance)
          assert_equal(2.to_m, gift_card.used)
        end
      end

      def test_refund
        VCR.use_cassette "#{gateway_cassette_name}/refund" do
          response = gateway.authorize(200, tender)
          assert(response.success?)

          response = gateway.refund(200, tender)

          assert(response.success?)
          assert(response.message.present?)

          gift_card.reload
          assert_equal(10.to_m, gift_card.balance)
          assert_equal(0.to_m, gift_card.used)
        end
      end

      def test_balance
        VCR.use_cassette "#{gateway_cassette_name}/balance" do
          balance = gateway.balance(gift_card.number)
          assert_equal(10.to_m, balance)

          gateway.authorize(300, tender)

          balance = gateway.balance(gift_card.number)
          assert_equal(7.to_m, balance)
        end
      end

      def test_lookup
        VCR.use_cassette "#{gateway_cassette_name}/lookup" do
          lookup = gateway.lookup(email: gift_card.to, token: gift_card.token)
          assert_equal(gift_card.id, lookup.id)

          lookup = gateway.lookup(email: 'foo', token: gift_card.token)
          assert_nil(lookup)
        end
      end
    end
  end
end
