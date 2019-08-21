Workarea.configure do |config|
  config.checkout_steps << 'Workarea::Checkout::Steps::GiftCard'
  config.customization_types << Workarea::Catalog::Customizations::GiftCard
  config.product_templates << :gift_card
  config.tender_types.prepend(:gift_card)
  config.seeds << 'Workarea::GiftCardSeeds'
  config.gift_card_token_length = 8
end
