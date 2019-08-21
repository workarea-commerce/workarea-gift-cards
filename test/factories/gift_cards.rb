require 'workarea/testing/factories'

module Workarea
  module Factories
    module GiftCards
      def create_gift_card(overrides = {})
        attributes = {
          to: 'bcrouse@workarea.com',
          amount: 10.to_m
        }.merge(overrides)

        Workarea::Payment::GiftCard.create!(attributes)
      end

      def create_gift_card_redemption(overrides = {})
        attributes = {
          amount: 10.to_m,
          redeemed_at: Time.now
        }.merge(overrides)

        Workarea::Payment::GiftCard::Redemption.create!(attributes)
      end
    end
  end
end

Workarea::Factories.add(Workarea::Factories::GiftCards)
