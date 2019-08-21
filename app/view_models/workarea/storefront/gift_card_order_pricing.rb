module Workarea
  module Storefront
    module GiftCardOrderPricing
      def gift_card
        return unless payment.gift_card.present?
        @gift_card ||= Workarea::Payment::GiftCard.find_by_token(
          payment.gift_card.number
        )
      end

      def gift_card_balance
        if gift_card.present?
          gift_card.balance
        else
          0.to_m
        end
      end

      def gift_card_amount
        if gift_card_balance > total_after_store_credit
          total_after_store_credit
        else
          gift_card_balance
        end
      end

      def total_after_store_credit
        order.total_price - store_credit_amount
      end

      def order_balance
        super - gift_card_amount
      end
    end
  end
end
