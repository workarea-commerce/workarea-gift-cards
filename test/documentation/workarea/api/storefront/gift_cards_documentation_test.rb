require 'test_helper'
require 'workarea/api/documentation_test' if Workarea::Plugin.installed?(:api)

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class GiftCardsDocumentationTest < DocumentationTest
          resource 'Gift Cards'

          def test_checking_gift_card_balance
            description 'Checking gift card balance'
            route storefront_api.gift_cards_balance_path
            parameter 'email', 'The to address on the gift card'
            parameter 'token', 'The gift card token to check the balance'
            explanation <<-EOS
              Use this endpoint to help a customer check the balance for one of
              their gift cards. The email and token params are required.
            EOS

            gift_card = create_gift_card(
              to: 'bcrouse@weblinc.com',
              amount: 5.to_m
            )

            record_request do
              get storefront_api.gift_cards_balance_path,
                  params: { email: 'bcrouse@weblinc.com', token: gift_card.token }

              assert_equal(200, response.status)
            end
          end

          def test_paying_with_a_gift_card
            description 'Checking out with a gift card'
            route storefront_api.add_gift_card_checkout_path(':order_id')
            explanation <<-EOS
              This endpoint adds a gift card to the payment to pay for this
              order. The amount will be taken from the gift card balance upon
              checkout completion.
            EOS

            product = create_product(
              name: 'Integration Product',
              variants: [
                { sku: 'SKU1',
                  regular: 6.to_m,
                  tax_code: '001',
                  on_sale: true,
                  sale: 5.to_m }
              ]
            )

            create_shipping_service(
              name: 'Ground',
              tax_code: '001',
              rates: [{ price: 7.to_m }]
            )

            gift_card = create_gift_card(amount: 5.to_m)

            order = Order.create!

            post storefront_api.cart_items_path(order),
                 params: {
                   product_id: product.id,
                   sku: product.skus.first,
                   quantity: 2
                 }

            patch storefront_api.checkout_path(order),
                  params: {
                    email: 'bcrouse@workarea.com',
                    billing_address: {
                      first_name:   'Ben',
                      last_name:    'Crouse',
                      street:       '12 N. 3rd St.',
                      city:         'Philadelphia',
                      region:       'PA',
                      postal_code:  '19106',
                      country:      'US',
                      phone_number: '2159251800'
                    },
                    shipping_address: {
                      first_name:   'Ben',
                      last_name:    'Crouse',
                      street:       '22 S. 3rd St.',
                      city:         'Philadelphia',
                      region:       'PA',
                      postal_code:  '19106',
                      country:      'US',
                      phone_number: '2159251800'
                    }
                  }

            record_request do
              patch storefront_api.add_gift_card_checkout_path(order),
                    params: { gift_card_number: gift_card.token }

              assert_equal(200, response.status)
            end
          end
        end
      end
    end
  end
end
