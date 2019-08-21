require 'test_helper'

module Workarea
  module Admin
    class GiftCardSystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      def test_managing_gift_cards
        visit admin.payment_gift_cards_path
        click_link 'add_payment_gift_card'

        fill_in 'gift_card[amount]', with: 75
        fill_in 'gift_card[to]', with: 'user@workarea.com'
        click_button 'create_gift_card'

        gift_card = Payment::GiftCard.first

        assert_current_path(admin.payment_gift_card_path(gift_card))
        assert(page.has_content?('Success'))
        assert(page.has_content?('$75.00'))

        click_link t('workarea.admin.actions.delete')

        assert_current_path(admin.payment_gift_cards_path)
        assert(page.has_no_content?(gift_card.name))
      end

      def test_filtering_gift_cards
        create_gift_card(token: '123', to: 'zac@workarea.com')
        create_gift_card(token: '456', to: 'owen@workarea.com')

        visit admin.payment_gift_cards_path(q: 'zac@workarea.com')
        assert(page.has_content?('123'))
        assert(page.has_no_content?('456'))

        visit admin.payment_gift_cards_path(q: '456')
        assert(page.has_content?('456'))
        assert(page.has_no_content?('123'))
      end

      def test_viewing_gift_card_redemptions
        gift_card = create_gift_card
        order = create_placed_order

        gift_card.redemptions.create!(
          order_id: order.id,
          amount: 1.to_m,
          redeemed_at: Time.now
        )

        visit admin.payment_gift_card_path(gift_card)

        click_link t('workarea.admin.payment_gift_cards.cards.redemptions.title')

        assert(page.has_content?(order.id))
        assert(page.has_content?(gift_card.token))
        assert(page.has_content?('$1.00'))
      end

      def test_exporting_gift_cards
        2.times { create_gift_card }

        visit admin.payment_gift_cards_path

        check 'select_all'
        click_button t('workarea.admin.shared.bulk_actions.export')

        fill_in 'export[emails_list]', with: 'bcrouse@workarea.com'
        click_button 'create_export'

        assert_current_path(admin.payment_gift_cards_path)
        assert(page.has_content?('Success'))
        assert(File.read(DataFile::Export.desc(:created_at).first.file.path).present?)

        visit admin.payment_gift_cards_path

        check 'select_all'
        click_button t('workarea.admin.payment_gift_cards.index.export_redemptions')

        fill_in 'export[emails_list]', with: 'bcrouse@workarea.com'
        click_button 'create_export'

        assert_current_path(admin.payment_gift_cards_path)
        assert(page.has_content?('Success'))
        assert(File.read(DataFile::Export.desc(:created_at).first.file.path).present?)
      end
    end
  end
end
