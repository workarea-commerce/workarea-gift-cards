module Workarea
  class Fulfillment
    module Policies
      class CreateGiftCard < Base
        def process(order_item:, fulfillment: nil)
          return unless Workarea::GiftCards.uses_system_cards?
          return unless order_item.gift_card?

          order_item.quantity.times do
            Payment::GiftCard.create!(
              amount: order_item.original_unit_price,
              order_id: order_item.order.id,
              to: order_item.customizations['email'],
              from: order_item.customizations['from'],
              message: order_item.customizations['message'],
              notify: true,
              purchased: true
            )
          end

          return unless fulfillment.present?
          fulfillment.mark_item_shipped(
            id: order_item.id.to_s,
            quantity: order_item.quantity
          )
        end
      end
    end
  end
end
