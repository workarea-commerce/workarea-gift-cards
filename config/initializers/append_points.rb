#
# Store Front
#
#
Workarea.append_partials(
  'storefront.checkout_summary_payment',
  'workarea/storefront/checkouts/gift_card_summary'
)

Workarea.append_partials(
  'storefront.payment_error',
  'workarea/storefront/checkouts/gift_card_error'
)

Workarea.append_partials(
  'storefront.secondary_payment',
  'workarea/storefront/checkouts/gift_card_payment'
)

Workarea.append_partials(
  'storefront.order_summary_payment',
  'workarea/storefront/orders/gift_card_summary'
)

Workarea.append_partials(
  'storefront.order_mailer_summary_payment',
  'workarea/storefront/order_mailer/gift_card_summary'
)

#
# Admin
#
#
Workarea.append_partials(
  'admin.orders_menu',
  'workarea/admin/payment_gift_cards/menu'
)
