module Workarea
  class SendGiftCardNotifications
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Payment::GiftCard => :create }, queue: 'low'

    def perform(gift_card_id)
      card = Payment::GiftCard.find(gift_card_id)
      return unless send_notification?(card)
      Storefront::GiftCardMailer.created(card.id.to_s).deliver_now
    end

    private

    def send_notification?(card)
      card.order_id.present? || (card.to.present? && card.notify?)
    end
  end
end
