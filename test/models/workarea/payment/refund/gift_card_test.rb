require 'test_helper'

module Workarea
  class Payment
    class Refund
      class GiftCardTest < TestCase
        def test_complete!
          tender = Workarea::Payment::Tender::GiftCard.new(number: 'token', amount: 5.to_m)
          transaction = tender.build_transaction(action: 'refund', amount: 5.to_m)

          Workarea::Payment::GiftCard.stubs(refund: true)
          Workarea::Payment::Refund::GiftCard.new(tender, transaction).complete!

          assert(transaction.response.present?)
        end
      end
    end
  end
end
