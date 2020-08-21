module Workarea
  class Checkout
    module Steps
      class GiftCard < Base
        # Updates the checkout to use a gift card as one of
        # its tenders.
        #
        # Sets pricing and reconciles tenders so the checkout
        # can know whether we need more payment.
        #
        # @param [Hash] params
        # @option params [String] :gift_card_number The gift card number to apply
        #
        # @return [Boolean] whether the update succeeded (payment were saved)
        #
        def update(params = {})
          gift_card_number = params[:gift_card_number].to_s.gsub(/\s+/, '') if params[:gift_card_number].present?

          payment.set_gift_card(number: gift_card_number) if valid_number?(gift_card_number)

          Pricing.perform(order, shippings)

          payment.adjust_tender_amounts(order.total_price)
        end

        # Whether this update to use a gift card succeeded.
        # If true, this was no gift card or a valid gift card applied,
        # false means the gift card number was invalid or expired.
        #
        # @return [Boolean]
        #
        def complete?
          !payment.gift_card? || (
            payment.gift_card.valid? &&
            valid_number?(payment.gift_card.number)
          )
        end

        private

        def valid_number?(number)
          return false unless number.present?
          Workarea::Payment::GiftCard.find_balance(number) > 0
        end
      end
    end
  end
end
