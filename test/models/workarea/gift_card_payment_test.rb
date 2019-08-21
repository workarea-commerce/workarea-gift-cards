require 'test_helper'

module Workarea
  class GiftCardPaymentTest < TestCase
    def test_add_gift_card
      Workarea.config.max_gift_cards_per_order = 2

      payment = create_payment

      assert(payment.add_gift_card(number: '1234'))
      assert_equal(1, payment.gift_cards.count)
      assert_equal('1234', payment.gift_cards.first.number)

      assert(payment.add_gift_card(number: '1234'))
      assert_equal(1, payment.gift_cards.count)

      assert(payment.add_gift_card(number: '3456'))
      assert_equal(2, payment.gift_cards.count)

      refute(payment.add_gift_card(number: '7890'))
      assert_equal(2, payment.gift_cards.count)
    end
  end
end
