module Workarea
  class LogGiftCardRedemption
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Order => :place,
        only_if: -> { Workarea::GiftCards.uses_system_cards? }
      }
    )

    def perform(order_id)
      order = Order.find(order_id)

      payment = Payment.find_or_initialize_by(id: order.id)
      return unless payment.gift_card?

      payment.gift_cards.each do |tender|
        gift_card = Payment::GiftCard.find_by_token(tender.number)
        next if redemption_already_exists?(gift_card, order.id)

        gift_card.redemptions.create!(
          redeemed_at: order.placed_at,
          amount: tender.amount,
          order_id: order.id
        )

        gift_card.touch
      end
    end

    private

    def redemption_already_exists?(card, order_id)
      card.redemptions.pluck(:order_id).include?(order_id)
    end
  end
end
