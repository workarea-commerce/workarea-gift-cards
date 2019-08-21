module Workarea
  class Payment::Tender::GiftCard < Payment::Tender
    field :number, type: String
    validates :number, presence: true

    def display_number
      "XXXX#{number.last(4)}"
    end

    def slug
      :gift_card
    end

    def amount=(amount)
      return super(amount) if amount.blank? || balance >= amount
      super(balance)
    end

    def balance
      @balance ||= Workarea::GiftCards.gateway.balance(number)
    end
  end
end
