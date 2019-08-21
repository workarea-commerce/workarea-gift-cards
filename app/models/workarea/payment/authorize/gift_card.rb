module Workarea
  class Payment
    module Authorize
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.authorize(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          return unless transaction.success?

          response = gateway.cancel(transaction.amount.cents, tender)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end
      end
    end
  end
end
