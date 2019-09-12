require 'test_helper'

module Workarea
  module Storefront
    class PurchaseGiftCardIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_generates_gift_card
        pass && (return) unless Workarea::GiftCards.uses_system_cards?

        product = create_product(
          name: 'Gift Card',
          gift_card: true,
          customizations: 'gift_card',
          variants: [{ sku: 'GIFTCARD', regular: 10.to_m }]
        )

        create_fulfillment_sku(id: 'GIFTCARD', policy: :create_gift_card)

        post storefront.cart_items_path,
             params: {
               product_id: product.id,
               sku:        product.skus.first,
               email:      'recipient@workarea.com',
               from:       'from@workarea.com',
               message:    'this is a message',
               quantity:   1
             }

        complete_checkout

        assert_equal(1, Payment::GiftCard.count)

        card = Payment::GiftCard.first
        assert_equal(10.to_m, card.amount)
        assert_equal(0.to_m, card.used)
        assert_equal(10.to_m, card.balance)
        assert(card.order_id.present?)
        assert(card.purchased?)

        assert_equal(2, ActionMailer::Base.deliveries.length)

        gift_card_email = ActionMailer::Base.deliveries.detect do |email|
          assert_includes(email.to, 'recipient@workarea.com')
        end

        gift_card_email.parts.each do |part|
          assert_includes(part.body, card.token)
          assert_includes(part.body, 'from@workarea.com')
          assert_includes(part.body, 'this is a message')
        end
      end
    end
  end
end
