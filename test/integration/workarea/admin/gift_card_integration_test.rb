require 'test_helper'

module Workarea
  module Admin
    class GiftCardIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.payment_gift_cards_path,
             params: {
               gift_card: {
                 to: 'ben@workarea.com',
                 from: 'bcrouse@workarea.com',
                 amount: 10,
                 notify: 1
               }
             }

        gift_card = Payment::GiftCard.first
        assert(gift_card.present?)
        assert_redirected_to(admin.payment_gift_card_path(gift_card))

        assert_equal('ben@workarea.com', gift_card.to)
        assert_equal('bcrouse@workarea.com', gift_card.from)
        assert_equal(10.to_m, gift_card.amount)
        assert(gift_card.notify?)

        gift_card_email = ActionMailer::Base.deliveries.detect do |email|
          assert_includes(email.to, 'ben@workarea.com')
        end
        gift_card_email.parts.each do |part|
          assert_includes(part.body, 'bcrouse@workarea.com')
        end
      end

      def test_update
        card = create_gift_card

        patch admin.payment_gift_card_path(card),
              params: { gift_card: { amount: 1_000_000 } }

        card.reload
        assert_equal(1_000_000.to_m, card.amount)
      end

      def test_destroy
        card = create_gift_card
        delete admin.payment_gift_card_path(card)
        assert(Payment::GiftCard.empty?)
      end
    end
  end
end
