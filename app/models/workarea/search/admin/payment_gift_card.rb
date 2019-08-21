module Workarea
  module Search
    class Admin
      class PaymentGiftCard < Search::Admin
        def type
          'gift_card'
        end

        def search_text
          [
            model.token,
            model.to,
            model.from,
            model.message
          ].join ' '
        end

        def jump_to_text
          "#{model.token} - balance: #{model.balance}"
        end

        def status
          if model.balance.zero?
            'redeemed'
          elsif model.used > 0
            'partially_redeemed'
          else
            'unredeemed'
          end
        end

        def created_by
          if model.order_id.present?
            'order'
          else
            'admin'
          end
        end

        def facets
          super.merge(created_by: created_by)
        end
      end
    end
  end
end
