module Workarea
  module Admin
    class PaymentGiftCardViewModel < ApplicationViewModel
      include CommentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end
    end
  end
end
