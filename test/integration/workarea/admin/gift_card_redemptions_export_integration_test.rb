require 'test_helper'

module Workarea
  module Admin
    class GiftCardRedemptionsExportIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_with_ids
        one = create_gift_card(amount: 20)
        two = create_gift_card(amount: 20)
        create_gift_card_redemption(gift_card: one, amount: 10)
        create_gift_card_redemption(gift_card: one, amount: 5)
        create_gift_card_redemption(gift_card: two, amount: 10)

        post admin.data_file_exports_path,
          params: {
            model_type: 'Workarea::Payment::GiftCard::Redemption',
            ids: [one.to_global_id],
            file_type: 'csv',
            emails:  ['test@workarea.com']
          }

        assert_equal(1, DataFile::Export.count)
        export = DataFile::Export.first
        results = CSV.read(export.file.path, headers: :first_row).map(&:to_h)
        assert_equal(2, results.length)
      end

      def test_with_search
        one = create_gift_card(amount: 20)
        two = create_gift_card(amount: 20)
        create_gift_card_redemption(gift_card: one, amount: 10)
        create_gift_card_redemption(gift_card: one, amount: 5)
        create_gift_card_redemption(gift_card: two, amount: 10)

        query = Search::AdminGiftCards.new(q: one.token)

        post admin.data_file_exports_path,
          params: {
            model_type: 'Workarea::Payment::GiftCard::Redemption',
            query_id: query.to_gid_param,
            file_type: 'csv',
            emails:  ['test@workarea.com']
          }

        assert_equal(1, DataFile::Export.count)
        export = DataFile::Export.first
        results = CSV.read(export.file.path, headers: :first_row).map(&:to_h)
        assert_equal(2, results.length)
      end

      def test_with_exclude
        one = create_gift_card(amount: 20)
        two = create_gift_card(amount: 20)
        create_gift_card_redemption(gift_card: one, amount: 10)
        create_gift_card_redemption(gift_card: one, amount: 5)
        create_gift_card_redemption(gift_card: two, amount: 10)

        query = Search::AdminGiftCards.new

        post admin.data_file_exports_path,
          params: {
            model_type: 'Workarea::Payment::GiftCard::Redemption',
            query_id: query.to_gid_param,
            exclude_ids: [two.to_gid_param],
            file_type: 'csv',
            emails:  ['test@workarea.com']
          }

        assert_equal(1, DataFile::Export.count)
        export = DataFile::Export.first
        results = CSV.read(export.file.path, headers: :first_row).map(&:to_h)
        assert_equal(2, results.length)
      end

      def test_multiple_pages
        Workarea.with_config do |config|
          config.per_page = 5
          config.bulk_action_per_page = 5

          15.times do
            card = create_gift_card(amount: 20)
            create_gift_card_redemption(gift_card: card, amount: 10)
          end

          query = Search::AdminGiftCards.new

          post admin.data_file_exports_path,
            params: {
              model_type: 'Workarea::Payment::GiftCard::Redemption',
              query_id: query.to_gid_param,
              file_type: 'csv',
              emails:  ['test@workarea.com']
            }

          assert_equal(1, DataFile::Export.count)
          export = DataFile::Export.first
          results = CSV.read(export.file.path, headers: :first_row).map(&:to_h)
          assert_equal(15, results.length)
        end
      end
    end
  end
end
