module Workarea
  module Admin
    class PaymentGiftCardsController < Admin::ApplicationController
      required_permissions :orders
      before_action :find_gift_card, except: :index

      def index
        search = Search::AdminGiftCards.new(params)
        @search = Admin::SearchViewModel.new(search, view_model_options)
      end

      def show; end

      def new; end

      def create
        if @gift_card.save
          flash[:success] = 'Gift card has been created.'
          redirect_to payment_gift_card_path(@gift_card)
        else
          render :new
        end
      end

      def edit; end

      def update
        if @gift_card.update_attributes(gift_card_params)
          flash[:success] = 'Gift card has been saved.'
          redirect_to payment_gift_card_path(@gift_card)
        else
          render :edit
        end
      end

      def destroy
        @gift_card.destroy
        flash[:success] = "Gift card #{@gift_card.token} has been removed."
        redirect_to payment_gift_cards_path
      end

      def redemptions
      end

      private

      def find_gift_card
        gift_card =
          if params[:id].present?
            Payment::GiftCard.find(params[:id])
          elsif params[:payment_gift_card_id].present?
            Payment::GiftCard.find(params[:payment_gift_card_id])
          else
            Payment::GiftCard.new(gift_card_params)
          end

        @gift_card =
          Admin::PaymentGiftCardViewModel.new(
            gift_card,
            view_model_options
          )
      end

      def gift_card_params
        return {} if params[:gift_card].blank?
        params[:gift_card].permit(
          :token,
          :to,
          :from,
          :message,
          :expires_at,
          :amount,
          :notify
        )
      end
    end
  end
end
