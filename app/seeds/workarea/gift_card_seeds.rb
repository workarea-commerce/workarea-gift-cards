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


      Workarea::Fulfillment::Sku.find_or_create_by(
        id: 'GIFT_CARD_10',
        policy: :create_gift_card
      )

      Workarea::Fulfillment::Sku.find_or_create_by(
        id: 'GIFT_CARD_25',
        policy: :create_gift_card
      )

      Workarea::Fulfillment::Sku.find_or_create_by(
        id: 'GIFT_CARD_50',
        policy: :create_gift_card
      )
    end
  end
end
