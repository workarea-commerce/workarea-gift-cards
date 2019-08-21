module Workarea
  class Payment
    module GiftCardOperation
      def gateway
        Workarea::GiftCards.gateway
      end
    end
  end
end
