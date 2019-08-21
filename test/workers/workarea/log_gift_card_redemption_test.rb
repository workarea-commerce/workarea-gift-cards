require 'test_helper'

module Workarea
  class LogGiftCardRedemptionTest < TestCase
    def test_perform
      gift_card = Payment::GiftCard.create!(token: '123456')

      order = Order.create!(placed_at: Time.now)
      payment = Payment.create!(id: order.id)
      payment.add_gift_card(number: '123456')

      LogGiftCardRedemption.new.perform(order.id)
      LogGiftCardRedemption.new.perform(order.id)

      gift_card.reload
      assert_equal(1, gift_card.redemptions.count)
    end
  end
end
