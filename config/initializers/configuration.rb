Workarea.configure do |config|
  config.product_templates << :gift_card
  config.customization_types << Workarea::Catalog::Customizations::GiftCard
  config.checkout_steps << 'Workarea::Checkout::Steps::GiftCard'
  config.tender_types.prepend(:gift_cards)
  config.seeds << 'Workarea::GiftCardSeeds'
  config.jump_to_navigation.merge!('Gift Cards' => :payment_gift_cards_path)

  config.gateways.gift_card = 'Workarea::GiftCards::Gateway'
end
