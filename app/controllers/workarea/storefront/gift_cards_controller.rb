module Workarea
  class Storefront::GiftCardsController < Storefront::ApplicationController
    def index
    end

    def lookup
      email = params.fetch(:email, nil)
      token = params.fetch(:token, nil)

      if email.present? && token.present?
        @gift_card = Workarea::Payment::GiftCard
                     .find_by_token_and_email(token, email)
      end

      if @gift_card.present?
        flash[:success] = "Your balance is #{@gift_card.balance.format}"
      else
        flash[:error] = 'Invalid card number or email.'
      end

      redirect_to gift_cards_balance_path
    end
  end
end
