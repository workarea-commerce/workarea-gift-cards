module Workarea
  module GiftCards
    class Gateway
      # Object returns from transaction requests.
      #
      # @attr [Boolean] success? whether the transaction was successful or not
      # @attr [String] message information on the transaction result
      #
      class Response < Struct.new(:success?, :message); end

      # Whether or not this gateway uses +Workarea::Payment::GiftCard+
      # This controls the display of the admin menu, triggering the creation of
      # cards from orders, and tracking redemptions.
      #
      def uses_system_cards?
        true
      end

      # See purchase. This gateway performs a purchase on authorization.
      #
      # @param [Integer] amount amount to authorize, in cents
      # @param [Workarea::Payment::Tender::GiftCard] tender for transaction
      #
      # @return [Workarea::GiftCards::Gateway::Response]
      #
      def authorize(amount, tender)
        purchase(amount, tender)
      end

      # See refund.
      #
      # @param [Integer] amount amount to cancel, in cents
      # @param [Workarea::Payment::Tender::GiftCard] tender for transaction
      #
      # @return [Workarea::GiftCards::Gateway::Response]
      #
      def cancel(amount, tender)
        refund(amount, tender)
      end

      # This gateway does a purchase on authorization so no capture is required.
      #
      # @param [Integer] amount amount to capture, in cents
      # @param [Workarea::Payment::Tender::GiftCard] tender for transaction
      #
      # @return [Workarea::GiftCards::Gateway::Response]
      #
      def capture(amount, tender)
        # no op, captures on authorization
        Response.new(true, I18n.t('workarea.gift_cards.capture'))
      end

      # Perform a purchase on a +Workarea::Payment::GiftCard+. This will
      # increment the `used` field, and decrement the `balance` field.
      #
      # @param [Integer] amount amount to purchase, in cents
      # @param [Workarea::Payment::Tender::GiftCard] tender for transaction
      #
      # @return [Workarea::GiftCards::Gateway::Response]
      #
      def purchase(amount, tender)
        Payment::GiftCard.purchase(tender.number, amount)

        Response.new(
          true,
          I18n.t(
            'workarea.gift_cards.debit',
            amount: amount,
            number: tender.number
          )
        )
      rescue Payment::InsufficientFunds
        Response.new(false, I18n.t('workarea.gift_cards.insufficient_funds'))
      end

      # Undo a purchase on a +Workarea::Payment::GiftCard+. This will
      # increment the `balance` field, and decrement the `used` field.
      #
      # @param [Integer] amount amount to refund, in cents
      # @param [Workarea::Payment::Tender::GiftCard] tender for transaction
      #
      # @return [Workarea::GiftCards::Gateway::Response]
      #
      def refund(amount, tender)
        Payment::GiftCard.refund(tender.number, amount)

        Response.new(
          true,
          I18n.t(
            'workarea.gift_cards.credit',
            amount: amount,
            number: tender.number
          )
        )
      end

      # Lookup the balance of one or many +Workarea::Payment::GiftCard+ records.
      # It will always return a single sum. If multiple numbers are provided, it
      # returns the total of all balances. Invalid numbers return a balance of
      # zero.
      #
      # @param [String] token the gift card number/token
      #
      # @return [Money] the balance gift cards matching the numbers provided
      #
      def balance(token)
        Array.wrap(token).sum(0.to_m) { |t| Payment::GiftCard.find_balance(t) }
      end

      # Lookup a gift card.
      #
      # @param [Hash] params
      # @option params [String] :email address associated to the gift card
      # @option params [String] :token gift card number/token to lookup
      #
      # @return [Workarea::Payment::GiftCard, nil]
      #
      def lookup(params)
        email = params.fetch(:email, nil)
        token = params.fetch(:token, nil)

        if email.present? && token.present?
          Workarea::Payment::GiftCard.find_by_token_and_email(token, email)
        end
      end
    end
  end
end
