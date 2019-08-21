module Workarea
  module Storefront
    class GiftCardMailer < Storefront::ApplicationMailer
      def created(card_id)
        @card = Payment::GiftCard.find(card_id)
        @from = from(@card.from, @card.order_id)

        mail(
          to: @card.to,
          from: Workarea.config.email_from,
          subject: t('workarea.storefront.email.gift_card_created.subject')
        )
      end

      private

      def from(card_from, order_id)
        card_from || card_order_email(order_id) || Workarea.config.email_from
      end

      def card_order_email(order_id)
        return unless order_id.present?
        order = Order.find(order_id)
        order.email
      end
    end
  end
end
