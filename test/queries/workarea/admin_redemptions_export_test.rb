require 'test_helper'

module Workarea
  class AdminRedemptionsExportTest < IntegrationTest
    def test_total
      Workarea.with_config do |config|
        config.per_page = 5
        config.bulk_action_per_page = 5

        card = create_gift_card(amount: 20)
        create_gift_card_redemption(gift_card: card, amount: 10)
        create_gift_card_redemption(gift_card: card, amount: 10)
        query = Search::AdminGiftCards.new

        export = AdminRedemptionsExport.new(gift_cards_query_id: query.to_gid_param)
        assert_equal(2, export.total)

        15.times do
          card = create_gift_card(amount: 20)
          create_gift_card_redemption(gift_card: card, amount: 10)
        end

        export = AdminRedemptionsExport.new(gift_cards_query_id: query.to_gid_param)
        assert_equal(17, export.total)
      end
    end

    def test_scroll
      Workarea.with_config do |config|
        config.bulk_action_per_page = 2

        5.times do
          card = create_gift_card(amount: 20)
          create_gift_card_redemption(gift_card: card, amount: 10)
        end

        query = Search::AdminGiftCards.new
        export = AdminRedemptionsExport.new(gift_cards_query_id: query.to_gid_param)
        count = 0
        passes = 0

        export.scroll do |results|
          count += results.size
          passes += 1
        end

        assert_equal(5, count)
        assert_equal(3, passes)
      end
    end
  end
end
