module Workarea
  module Storefront
    class GiftCardMailerPreview < ActionMailer::Preview
      def created
        card = Payment::GiftCard.create!(
          amount: '100',
          order_id: 'WL-123456',
          to: 'to@example.com',
          from: 'from@example.com',
          message: 'Gift card message body',
          notify: true,
          purchased: true
        )
        GiftCardMailer.created(card.id)
      end
    end
  end
end
