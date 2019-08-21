module Workarea
  if Plugin.installed?(:api)
    module Api
      module Admin
        class PaymentGiftCardsController < Admin::ApplicationController
          before_action :find_gift_card, except: [:index, :create]

          def index
            @gift_cards = Payment::GiftCard
                          .all
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

            respond_with gift_cards: @gift_cards
          end

          def show
            respond_with gift_card: @gift_card
          end

          def update
            @gift_card.update_attributes!(params[:gift_card])
            respond_with gift_card: @gift_card
          end

          def create
            @gift_card = Payment::GiftCard.create!(params[:gift_card])
            respond_with(
              { gift_card: @gift_card },
              { status: :created,
              location: payment_gift_card_path(@gift_card) }
            )
          end

          def destroy
            @gift_card.destroy
            head :no_content
          end

          private

          def find_gift_card
            @gift_card = Payment::GiftCard.find(params[:id])
          end
        end
      end
    end
  end
end
