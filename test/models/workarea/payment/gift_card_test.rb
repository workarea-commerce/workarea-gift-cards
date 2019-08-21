require 'test_helper'

module Workarea
  class Payment
    class GiftCardTest < TestCase
      def test_not_expired
        expired     = Workarea::Payment::GiftCard.create!(amount: 10.to_m, expires_at: Time.now - 1.day)
        not_expired = Workarea::Payment::GiftCard.create!(amount: 10.to_m, expires_at: Time.now + 1.day)
        no_date     = Workarea::Payment::GiftCard.create!(amount: 10.to_m, expires_at: '')

        results = Workarea::Payment::GiftCard.not_expired.to_a
        assert_includes(results, not_expired)
        assert_includes(results, no_date)
        refute_includes(results, expired)
      end

      def test_search_by_token_or_recipient
        one = Workarea::Payment::GiftCard.create!(amount: 10.to_m, token: '123', to: 'zac@workarea.com')
        two = Workarea::Payment::GiftCard.create!(amount: 10.to_m, token: '456', to: 'owen@workarea.com')

        results = Workarea::Payment::GiftCard
                  .search_by_token_or_recipient('zac@workarea.com')

        assert_includes(results, one)
        refute_includes(results, two)
      end

      def test_purchase
        card = Workarea::Payment::GiftCard.create!(amount: 10.to_m)

        card.purchase(500)
        card.reload
        assert_equal(10.to_m, card.amount)
        assert_equal(5.to_m, card.balance)
        assert_equal(5.to_m, card.used)

        assert_raise(Payment::InsufficientFunds) do
          card.purchase(5000)
        end
      end

      def test_refund_class_method
        card = Workarea::Payment::GiftCard.create!(amount: 10.to_m)

        Workarea::Payment::GiftCard.refund(card.token, 500)
        card.reload

        assert_equal(10.to_m, card.amount)
        assert_equal(15.to_m, card.balance)
        assert_equal(-5.to_m, card.used)
      end

      def test_refund_instance_method
        card = Workarea::Payment::GiftCard.create!(amount: 10.to_m)

        card.refund(500)
        card.reload
        assert_equal(10.to_m, card.amount)
        assert_equal(15.to_m, card.balance)
        assert_equal(-5.to_m, card.used)
      end

      def test_find_by_token_and_email
        card = Workarea::Payment::GiftCard.create!(
          amount: 10.to_m,
          token: '123',
          to: 'test@workarea.com'
        )

        assert_equal(
          card,
          Workarea::Payment::GiftCard.find_by_token_and_email(
            '123',
            'test@workarea.com'
          )
        )

        assert_nil(
          Workarea::Payment::GiftCard.find_by_token_and_email(
            '123',
            'noone@workarea.com'
          )
        )

        assert_nil(
          Workarea::Payment::GiftCard.find_by_token_and_email(
            '321',
            'test@workarea.com'
          )
        )
      end

      def test_to=
        card =
          Workarea::Payment::GiftCard.create!(
            amount: 10.to_m,
            token: 'TESTTOKEN',
            to: 'TEST@WORKAREA.COM'
          )

        assert_equal('test@workarea.com', card.to)
        assert_equal('testtoken', card.token)

        card.to = nil
        assert_nil(card.to)
      end

      def test_last_redeemed_at
        card =
          Workarea::Payment::GiftCard.create!(
            amount: 2.to_m,
            token: '123',
            to: 'test@workarea.com'
          )

        assert_nil(card.last_redeemed_at)

        one_day_ago = 1.day.ago
        two_days_ago = 2.days.ago
        card.redemptions.create!(amount: 1.to_m, redeemed_at: one_day_ago)
        card.redemptions.create!(amount: 1.to_m, redeemed_at: two_days_ago)

        assert_equal(one_day_ago.to_i, card.last_redeemed_at.to_i)
      end
    end
  end
end
