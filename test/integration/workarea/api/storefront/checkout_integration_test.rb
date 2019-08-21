require 'test_helper'

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class CheckoutIntegrationTest < Workarea::IntegrationTest
          setup :tax, :product, :shipping_service, :gift_card

          def tax
            @tax ||= create_tax_category(
              name: 'Sales Tax',
              code: '001',
              rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
            )
          end

          def product
            @product ||= create_product(
              name: 'Integration Product',
              variants: [
                { sku: 'SKU1',
                  regular: 6.to_m,
                  tax_code: '001',
                  on_sale: true,
                  sale: 5.to_m }
              ]
            )
          end

          def shipping_service
            @shipping_service ||= create_shipping_service(
              name: 'Ground',
              tax_code: '001',
              rates: [{ price: 7.to_m }]
            )
          end

          def gift_card
            @gift_card ||= create_gift_card(amount: 5.to_m)
          end

          def complete_checkout
            post storefront_api.carts_path
            order_id = JSON.parse(response.body)['id']

            post storefront_api.cart_items_path(order_id),
                 params: {
                   product_id: product.id,
                   sku: product.skus.first,
                   quantity: 2
                 }

            patch storefront_api.checkout_path(order_id),
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

            patch storefront_api.add_gift_card_checkout_path(order_id),
                  params: { gift_card_number: gift_card.token }

            post storefront_api.complete_checkout_path(order_id),
                 params: {
                   payment: 'new_card',
                   credit_card: {
                     number: '1',
                     month: '1',
                     year: Time.now.year + 1,
                     cvv: '999'
                   }
                 }
          end

          def test_saves_order_info
            complete_checkout

            order = Order.first

            assert_equal('bcrouse@workarea.com', order.email)
            assert(order.placed_at.present?)
            assert_equal(1, order.items.length)

            assert_equal(product.id, order.items.first.product_id)
            assert_equal(product.skus.first, order.items.first.sku)
            assert_equal(2, order.items.first.quantity)

            assert_equal(10.to_m, order.items.first.total_price)
            assert_equal(1, order.items.first.price_adjustments.length)
            assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)

            assert(order.items.first.on_sale?)
            assert(order.items.first.product_attributes.present?)

            payment = Payment.find(order.id)
            assert_equal('Ben', payment.first_name)
            assert_equal('Crouse', payment.last_name)
            assert_equal('Ben', payment.address.first_name)
            assert_equal('Crouse', payment.address.last_name)
            assert_equal('12 N. 3rd St.', payment.address.street)
            assert_equal('Philadelphia', payment.address.city)
            assert_equal('PA', payment.address.region)
            assert_equal('19106', payment.address.postal_code)
            assert_equal('US', payment.address.country.alpha2)
            assert_equal('2159251800', payment.address.phone_number)

            assert_equal('Test Card', payment.credit_card.issuer)
            assert_equal('XXXX-XXXX-XXXX-1', payment.credit_card.display_number)
            assert_equal(1, payment.credit_card.month)
            assert(payment.credit_card.year.present?)
            assert_equal(13.19.to_m, payment.credit_card.amount)
            assert(payment.credit_card.token.present?)
            assert(payment.credit_card.saved_card_id.blank?)

            assert_equal(1, payment.credit_card.transactions.length)
            assert(payment.credit_card.transactions.first.response.present?)
            assert_equal(13.19.to_m, payment.credit_card.transactions.first.amount)

            assert_equal(gift_card.token, payment.gift_card.number)
            assert_equal(5.to_m, payment.gift_card.amount)
            assert_equal(1, payment.gift_card.transactions.length)
            assert_equal(5.to_m, payment.gift_card.transactions.first.amount)
          end

          def test_reduces_balance_on_gift_card
            complete_checkout

            gift_card.reload
            assert_equal(0.to_m, gift_card.balance)
            assert_equal(5.to_m, gift_card.amount)
            assert_equal(5.to_m, gift_card.used)

            order = Order.first
            redemption = gift_card.redemptions.first
            assert_equal(order.placed_at, redemption.redeemed_at)
            assert_equal(5.to_m, redemption.amount)
          end
        end
      end
    end
  end
end
