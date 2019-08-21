require 'test_helper'

module Workarea
  module Storefront
    class GiftCardSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_putting_a_gift_card_in_your_cart
        product = create_product(
          name: 'Gift Card',
          gift_card: true,
          digital: true,
          template: 'gift_card',
          customizations: 'gift_card',
          variants: [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 15.to_m },
            { sku: 'SKU3', regular: 25.to_m }
          ]
        )

        visit storefront.product_path(product)

        assert(page.has_content?('Gift Card'))

        within '.product-details__add-to-cart-form' do
          select product.skus.first, from: 'sku'
          wait_for_xhr

          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'from', with: 'Ben Crouse'
          fill_in 'message', with: 'this is a message'

          click_button 'add_to_cart'
          wait_for_xhr
        end

        visit storefront.cart_path

        assert(page.has_content?('Gift Card'))
        assert(page.has_content?('bcrouse@workarea.com'))
        assert(page.has_content?('Ben Crouse'))
        assert(page.has_content?('this is a message'))
      end

      def test_purchasing_digital_gift_cards
        setup_checkout_specs
        Workarea::Order.first.items.delete_all

        product = create_product(
          name: 'Gift Card',
          gift_card: true,
          digital: true,
          template: 'gift_card',
          customizations: 'gift_card',
          variants:  [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 15.to_m },
            { sku: 'SKU3', regular: 25.to_m }
          ]
        )

        visit storefront.product_path(product)

        within '.product-details__add-to-cart-form' do
          select product.skus.first, from: 'sku'
          wait_for_xhr

          fill_in 'email', with: 'recipient@workarea.com'
          fill_in 'from', with: 'sender@workarea.com'
          fill_in 'message', with: 'this is a message'

          click_button 'add_to_cart'
          wait_for_xhr
        end

        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)

        refute(page.has_selector?('#shipping_address_first_name'))
        refute(page.has_selector?('#shipping_address_last_name'))

        fill_in_email
        fill_in_billing_address
        click_button 'continue'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        fill_in_credit_card
        click_button 'place_order'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Workarea::Order.first.id))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Test Card'))
        assert(page.has_content?('XX-1'))

        assert(page.has_content?('Gift Card'))
        assert(page.has_content?('recipient@workarea.com'))
        assert(page.has_content?('Ben Crouse'))
        assert(page.has_content?('this is a message'))
        assert(page.has_content?('$10.00'))
      end

      def test_guest_purchasing_with_a_gift_card
        gift_card = create_gift_card(amount: 100.to_m)

        setup_checkout_specs
        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button 'continue'

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button 'continue'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.gift_cards.enter_gift_card_prompt')
        fill_in 'gift_card_number', with: gift_card.token
        click_button 'apply_gift_card'

        assert_current_path(storefront.checkout_payment_path)

        assert(page.has_content?('Success'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Gift Card'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$12.84'))

        click_button 'place_order'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Workarea::Order.first.id))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Gift Card'))
        assert(page.has_content?("XXXX#{gift_card.token.last(4)}"))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$12.84'))
      end

      def test_logged_in_user_purchasing_with_a_gift_card
        gift_card = create_gift_card(amount: 100.to_m)

        setup_checkout_specs
        add_user_data
        start_user_checkout

        assert_current_path(storefront.checkout_payment_path)

        click_button t('workarea.storefront.gift_cards.enter_gift_card_prompt')
        fill_in 'gift_card_number', with: gift_card.token
        click_button 'apply_gift_card'

        assert_current_path(storefront.checkout_payment_path)

        assert(page.has_content?('Success'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Gift Card'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$12.84'))

        click_button 'place_order'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Workarea::Order.first.id))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_no_content?('Test Card'))
        assert(page.has_no_content?('XX-1'))
        assert(page.has_content?('Gift Card'))
        assert(page.has_content?("XXXX#{gift_card.token.last(4)}"))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$12.84'))
      end

      def test_purchasing_with_a_gift_card_and_a_credit_card
        gift_card = create_gift_card(amount: 5.to_m, token: 'MixEdCaSe')

        setup_checkout_specs
        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        uncheck 'same_as_shipping'
        fill_in_billing_address
        fill_in_shipping_address
        click_button 'continue'

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button 'continue'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.gift_cards.enter_gift_card_prompt')
        fill_in 'gift_card_number', with: gift_card.token
        click_button 'apply_gift_card'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Gift Card'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.84'))

        fill_in_credit_card
        click_button 'place_order'

        assert_current_path(storefront.checkout_confirmation_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Workarea::Order.first.id))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Test Card'))
        assert(page.has_content?('XX-1'))
        assert(page.has_content?('Gift Card'))
        assert(page.has_content?("XXXX#{gift_card.token.last(4)}"))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.00'))
        assert(page.has_content?('$0.84'))
        assert(page.has_content?('$5.00'))
        assert(page.has_content?('$7.84'))
      end

      def test_trying_to_pay_with_an_insufficient_gift_card_amount
        gift_card = create_gift_card(amount: 1.to_m)

        setup_checkout_specs
        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button 'continue'

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button 'continue'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.gift_cards.enter_gift_card_prompt')
        fill_in 'gift_card_number', with: gift_card.token
        click_button 'apply_gift_card'

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('$1.00'))
        assert(page.has_content?('$11.84'))

        click_button 'place_order'

        # js prevents submit and focuses on credit card
        assert_current_path(storefront.checkout_payment_path)

        fill_in_credit_card
        click_button 'place_order'
        assert(page.has_content?('Success'))
        assert_current_path(storefront.checkout_confirmation_path)
      end

      def test_check_a_gift_card_balance
        gift_card = create_gift_card(amount: 5.to_m)

        visit storefront.gift_cards_balance_path
        fill_in 'gift_card_number', with: gift_card.token
        fill_in 'gift_card_email', with: gift_card.to
        click_button 'submit'

        assert(page.has_content?('$5.00'))
      end

      def test_check_a_gift_card_balance_with_a_mis_cased_email
        gift_card = create_gift_card(amount: 5.to_m)

        visit storefront.gift_cards_balance_path
        fill_in 'gift_card_number', with: gift_card.token
        fill_in 'gift_card_email', with: gift_card.to.upcase
        click_button 'submit'

        assert(page.has_content?('$5.00'))
      end
    end
  end
end
