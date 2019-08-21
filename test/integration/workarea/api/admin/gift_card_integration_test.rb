require 'test_helper'

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Admin
        class GiftCardIntegrationTest < IntegrationTest
          include Workarea::Admin::IntegrationTest
          setup :set_sample_attributes

          def set_sample_attributes
            @sample_attributes = create_gift_card.as_json.except('_id')
          end

          def test_lists_gift_cards
            gift_cards = [create_gift_card(to: 'test@email.com'), create_gift_card(to: 'foo@weblinc.com')]
            get admin_api.gift_cards_path
            result = JSON.parse(response.body)['gift_cards']

            assert_equal(3, result.length)
            assert_equal(gift_cards.second, Payment::GiftCard.new(result.first))
            assert_equal(gift_cards.first, Payment::GiftCard.new(result.second))
          end

          def test_creates_gift_cards
            assert_difference 'Payment::GiftCard.count', 1 do
              post admin_api.gift_cards_path,
                   params: { gift_card: @sample_attributes.merge('to' => 'test@email.com').except('token') }
            end
          end

          def test_shows_gift_cards
            gift_card = create_gift_card(to: 'foo@weblinc.com')
            get admin_api.gift_card_path(gift_card.id)
            result = JSON.parse(response.body)['gift_card']
            assert_equal(gift_card, Payment::GiftCard.new(result))
          end

          def test_updates_gift_cards
            gift_card = create_gift_card(to: 'foo@weblinc.com')
            patch admin_api.gift_card_path(gift_card.id),
                  params: { gift_card: { to: 'bar@weblinc.com' } }

            assert_equal('bar@weblinc.com', gift_card.reload.to)
          end

          def test_destroys_gift_cards
            gift_card = create_gift_card(to: 'foo@weblinc.com')
            assert_difference 'Payment::GiftCard.count', -1 do
              delete admin_api.gift_card_path(gift_card.id)
            end
          end

          def test_bulk_upserts_gift_cards
            data = Array.new(10) { |i| @sample_attributes.merge('token' => "GC#{i}") }

            assert_difference 'Payment::GiftCard.count', 10 do
              patch admin_api.bulk_gift_cards_path, params: { gift_cards: data }
            end
          end
        end
      end
    end
  end
end
