module Workarea
  class Checkout
    module Steps
      class GiftCard < Base
        # Add a gift card tender to the order, updates pricing and adjusts the
        # tender amounts for all existing tenders.
        #
        # @param [Hash] params
        # @option params [String] :gift_card_number a gift card number to apply
        #
        # @return [Boolean] whether the update succeeded (payment were saved)
        #
        def update(params = {})
          gift_card_params = extract_gift_card_params(params)

          add_gift_card(gift_card_params) if applicable_gift_card?(gift_card_params)

          update_order
        end

        # Removes a gift card from payment, updates order pricing and readjusts
        # tender amounts.
        #
        # @param [String] id the gift card tender id
        #
        # @return [Boolean] whether the update succeeded (payment was saved)
        #
        def remove(id)
          payment.gift_cards.find(id).destroy
        rescue Mongoid::Errors::DocumentNotFound
          # no op
        ensure
          update_order
        end

        # Whether this step of checkout is considered complete. Requires either
        # no gift cards applied, or that all gift cards are valid with a
        # balance. No balance could mean a card is expired, or has been used.
        #
        # @return [Boolean]
        #
        def complete?
          !payment.gift_card? ||
            (
              payment.gift_cards.all?(&:valid?) &&
              payment.gift_cards.none? { |g| g.balance.zero? }
            )
        end

        private

        def extract_gift_card_params(params)
          { number: params[:gift_card_number].to_s.gsub(/\s+/, '') }
        end

        def applicable_gift_card?(params)
          return false unless params[:number].present?
          Workarea::GiftCards.gateway.balance(params[:number]) > 0
        end

        def add_gift_card(params)
          payment.add_gift_card(params)
        end

        def update_order
          Pricing.perform(order, shippings)
          payment.adjust_tender_amounts(order.total_price)
        end
      end
    end
  end
end
