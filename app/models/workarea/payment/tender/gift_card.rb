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
      if amount.blank?
        super(amount)
      elsif balance >= amount
        super(amount)
      else
        super(balance)
      end
    end

    private

    def balance
      @balance ||= Payment::GiftCard.find_balance(number)
    end
  end
end
