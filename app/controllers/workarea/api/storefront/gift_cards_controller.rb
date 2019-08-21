module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class GiftCardsController < Api::Storefront::ApplicationController
          def balance
            @gift_card = Workarea::GiftCards.gateway.lookup(params)

            if @gift_card.blank?
              raise Mongoid::Errors::DocumentNotFound.new(
                Payment::GiftCard,
                params.to_unsafe_h.except('controller', 'action')
              )
            end
          end
        end
      end
    end
  end
end
