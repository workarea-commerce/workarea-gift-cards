module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class GiftCardsController < Api::Storefront::ApplicationController
          def balance
            email = params.fetch(:email, nil)
            token = params.fetch(:token, nil)

            if email.present? && token.present?
              @gift_card = Payment::GiftCard.find_by_token_and_email(token, email)
            end

            if @gift_card.blank?
              raise Mongoid::Errors::DocumentNotFound.new(
                Payment::GiftCard,
                email: email,
                token: token
              )
            end
          end
        end
      end
    end
  end
end
