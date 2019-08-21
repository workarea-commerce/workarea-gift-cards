require 'test_helper'

module Workarea
  class Payment
    module Purchase
      class GiftCardTest < TestCase
        setup :gift_card

        def gift_card
          @gift_card ||= Payment::GiftCard.create!(token: 'token', amount: 5.to_m)
        end

        def payment
          @payment ||= create_payment
        end

        def test_complete!
          payment.add_gift_card(number: 'token')
          gift_card = payment.gift_cards.first

          transaction = gift_card.build_transaction(amount: 10.to_m)

          GiftCard.new(gift_card, transaction).complete!
          refute(transaction.success?)
          assert(transaction.message.present?)

          transaction = gift_card.build_transaction(amount: 3.to_m)
          purchase = GiftCard.new(gift_card, transaction)
          purchase.complete!

          assert(transaction.success?)
          assert_equal(3.to_m, transaction.amount)
        end

        def test_cancel!
          payment.add_gift_card(number: 'token')
          gift_card = payment.gift_cards.first

          transaction = gift_card.build_transaction(amount: 5.to_m)

          purchase = GiftCard.new(gift_card, transaction)
          purchase.cancel!

          refute(transaction.cancellation.present?)

          purchase.complete!
          assert(transaction.success?)

          purchase.cancel!
          assert(transaction.cancellation.present?)
        end
      end
    end
  end
end
