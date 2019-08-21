module Workarea
  class Payment
    module Purchase
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.purchase(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          return unless transaction.success?

          response = gateway.refund(transaction.amount.cents, tender)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end
      end
    end
  end
end
