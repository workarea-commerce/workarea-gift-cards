require 'test_helper'
require 'workarea/api/documentation_test' if Workarea::Plugin.installed?(:api)

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Admin
        class GiftCardsDocumentationTest < DocumentationTest
          include Workarea::Admin::IntegrationTest

          def sample_attributes
            @sample_attributes = create_gift_card.as_json.except('_id')
          end

          resource 'Payment Gift Cards'

          def test_and_document_index
            description 'Listing payment gift cards'
            route admin.payment_gift_cards_path
            parameter :page, 'Current page'
            parameter :sort_by, 'Field on which to sort (see responses for possible values)'
            parameter :sort_direction, 'Direction to sort (asc or desc)'
            2.times { |i| create_gift_card(to: "#{i}@weblinc.com") }

            record_request do
              get admin_api.payment_gift_cards_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

              assert_equal(200, response.status)
            end
          end

          def test_and_document_create
            description 'Creating a gift card'
            route admin_api.payment_gift_cards_path

            record_request do
              post admin_api.payment_gift_cards_path,
                   params: { gift_card: sample_attributes.merge('token' => 'foobar') },
                   as: :json

              assert_equal(201, response.status)
            end
          end

          def test_and_document_show
            description 'Showing a gift card'
            route admin_api.payment_gift_card_path(':id')

            record_request do
              get admin_api.payment_gift_card_path(create_gift_card.id)
              assert_equal(200, response.status)
            end
          end

          def test_and_document_update
            description 'Updating a gift card'
            route admin_api.payment_gift_card_path(':id')

            record_request do
              patch admin_api.payment_gift_card_path(create_gift_card.id),
                    params: { gift_card: { to: 'test@weblinc.com' } },
                    as: :json

              assert_equal(204, response.status)
            end
          end

          def test_and_document_destroy
            description 'Removing a gift card'
            route admin_api.payment_gift_card_path(':id')

            record_request do
              delete admin_api.payment_gift_card_path(create_gift_card.id)
              assert_equal(204, response.status)
            end
          end
        end
      end
    end
  end
end
