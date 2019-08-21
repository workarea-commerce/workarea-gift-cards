module Workarea
  module Storefront
    module Checkout
      class GiftCardsController < CheckoutsController
        def add
          step = Workarea::Checkout::Steps::GiftCard.new(current_checkout)

          if step.update(params)
            flash[:success] = t('workarea.storefront.flash_messages.gift_card_added')
            redirect_to checkout_payment_path
          else
            @step = Storefront::Checkout::PaymentViewModel.new(
              step,
              view_model_options
            )

            flash[:error] = t('workarea.storefront.flash_messages.gift_card_error')
            render :payment
          end
        end

        def remove
          step = Workarea::Checkout::Steps::GiftCard.new(current_checkout)
          step.remove(params[:gift_card_id])

          flash[:success] = t('workarea.storefront.flash_messages.gift_card_removed')
          redirect_to checkout_payment_path
        end
      end
    end
  end
end
