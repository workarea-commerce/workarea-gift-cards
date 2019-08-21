module Workarea
  class CreateOrderedGiftCards
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Fulfillment => :create }

    def perform(order_id)
      order = Order.find(order_id)
      fulfillment = Fulfillment.find(order.id)

      gift_cards = order.items.select do |item|
        item.digital? && item.gift_card?
      end

      gift_cards.each do |item|
        unit_adjustment = item.price_adjustments.first
        unit_amount = unit_adjustment.amount / item.quantity

        item.quantity.times do
          Payment::GiftCard.create!(
            amount: unit_amount,
            order_id: order.id,
            to: item.customizations['email'],
            from: item.customizations['from'],
            message: item.customizations['message'],
            notify: true,
            purchased: true
          )
        end

        update_fulfillment(fulfillment, item)
      end
    end

    private

    def update_fulfillment(fulfillment, item)
      # Ensure item is there to ship
      fulfillment.items.detect { |i| i.order_item_id == item.id.to_s } ||
        fulfillment.items.build(order_item_id: item.id, quantity: item.quantity)

      fulfillment.mark_item_shipped(id: item.id.to_s, quantity: item.quantity)
      fulfillment.save!
    end
  end
end
