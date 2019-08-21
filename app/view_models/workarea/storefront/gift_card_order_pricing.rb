module Workarea
  module Storefront
    module GiftCardOrderPricing
      extend ActiveSupport::Concern

      def gift_cards
        @gift_cards ||= payment.gift_cards.select(&:persisted?)
      end

      def gift_card?
        gift_cards.present?
      end

      def gift_card_amount
        gift_cards.sum(0.to_m, &:amount)
      end

      def gift_card_balance
        gift_cards.sum(0.to_m, &:balance)
      end

      def total_before_gift_cards
        order.total_price - advance_payment_amount + gift_card_amount
      end

      def advance_payment_amount
        super + gift_card_amount
      end

      def failed_gift_card
        @failed_gift_card ||= payment.gift_cards.reject(&:persisted?).first
      end
    end
  end
end
