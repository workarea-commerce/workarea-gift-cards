module Workarea
  class GiftCardSeeds
    def perform
      puts 'Adding gift cards...'
      add_gift_card_product
    end

    private

    def add_gift_card_product
      product = Workarea::Catalog::Product.new(
        id: 'GIFT_CARD',
        name: 'Gift Card',
        gift_card: true,
        digital: true,
        template: 'gift_card',
        customizations: 'gift_card',
        description: Faker::Lorem.paragraph,
        variants: [
          { sku: 'GIFT_CARD_10' },
          { sku: 'GIFT_CARD_25' },
          { sku: 'GIFT_CARD_50' }
        ]
      )

      product.save!

      Workarea::Pricing::Sku.find_or_create_by(
        id: 'GIFT_CARD_10',
        prices: [{ regular: 10 }]
      )

      Workarea::Pricing::Sku.find_or_create_by(
        id: 'GIFT_CARD_25',
        prices: [{ regular: 25 }]
      )

      Workarea::Pricing::Sku.find_or_create_by(
        id: 'GIFT_CARD_50',
        prices: [{ regular: 50 }]
      )
    end
  end
end
