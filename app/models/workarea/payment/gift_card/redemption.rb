module Workarea
  class Payment
    class GiftCard
      class Redemption
        include ApplicationDocument

        field :redeemed_at, type: DateTime
        field :order_id, type: String

        field :amount, type: Money

        belongs_to :gift_card, class_name: 'Workarea::Payment::GiftCard'

        validates_presence_of :amount
        validates_presence_of :redeemed_at

        index(redeemed_at: 1)
        index(order_id: 1)
        index(gift_card_id: 1)
      end
    end
  end
end
