module Workarea
  class Payment
    module Authorize
      class GiftCard
        include OperationImplementation

        def complete!
          Payment::GiftCard.purchase(tender.number, transaction.amount.cents)

          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.gift_cards.debit',
              amount: transaction.amount,
              number: tender.number
            )
          )

        rescue Payment::InsufficientFunds
          transaction.response = ActiveMerchant::Billing::Response.new(
            false,
            I18n.t('workarea.gift_cards.insufficient_funds')
          )
        end

        def cancel!
          return unless transaction.success?

          Payment::GiftCard.refund(tender.number, transaction.amount.cents)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.gift_cards.credit',
              amount: transaction.amount,
              number: tender.number
            )
          )
        end
      end
    end
  end
end
