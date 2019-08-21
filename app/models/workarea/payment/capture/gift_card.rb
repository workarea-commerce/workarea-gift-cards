module Workarea
  class Payment
    class Capture
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.capture(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          # noop, nothing to cancel
        end
      end
    end
  end
end
