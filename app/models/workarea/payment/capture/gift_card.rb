module Workarea
  class Payment
    class Capture
      class GiftCard
        include OperationImplementation

        def complete!
          # noop, authorization does the capture
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t('workarea.gift_cards.capture')
          )
        end

        def cancel!
          # noop, nothing to cancel
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t('workarea.gift_cards.capture')
          )
        end
      end
    end
  end
end
