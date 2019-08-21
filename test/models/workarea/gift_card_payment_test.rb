require 'test_helper'

module Workarea
  class GiftCardPaymentTest < TestCase
    def test_set_gift_card
      payment = create_payment

      payment.set_gift_card(number: '1234')
      assert_equal('1234', payment.gift_card.number)
    end
  end
end
