module Workarea
  if Plugin.installed?(:api)
    module Api
      module Admin
        class GiftCardsController < Admin::ApplicationController
          before_action :find_gift_card, except: [:index, :create, :bulk]

          swagger_path '/gift_cards' do
            operation :get do
              key :summary, 'All Gift cards'
              key :description, 'Returns all gift cards from the system'
              key :operationId, 'listGiftCards'
              key :produces, ['application/json']

              parameter do
                key :name, :page
                key :in, :query
                key :description, 'Current page'
                key :required, false
                key :type, :integer
                key :default, 1
              end
              parameter do
                key :name, :sort_by
                key :in, :query
                key :description, 'Field on which to sort (see responses for possible values)'
                key :required, false
                key :type, :string
                key :default, 'created_at'
              end
              parameter do
                key :name, :sort_direction
                key :in, :query
                key :description, 'Direction for sort by'
                key :type, :string
                key :enum, %w(asc desc)
                key :default, 'desc'
              end

              response 200 do
                key :description, 'Gift cards'
                schema do
                  key :type, :object
                  property :gift_cards do
                    key :type, :array
                    items do
                      key :'$ref', 'Workarea::Payment::GiftCard'
                    end
                  end
                end
              end
            end

            operation :post do
              key :summary, 'Create GiftCard'
              key :description, 'Creates a new gift_card.'
              key :operationId, 'addGiftCard'
              key :produces, ['application/json']

              parameter do
                key :name, :body
                key :in, :body
                key :description, 'GiftCard to add'
                key :required, true
                schema do
                  key :type, :object
                  property :gift_card do
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end

              response 201 do
                key :description, 'Gift card created'
                schema do
                  key :type, :object
                  property :gift_card do
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end

              response 422 do
                key :description, 'Validation failure'
                schema do
                  key :type, :object
                  property :problem do
                    key :type, :string
                  end
                  property :document do
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end
            end
          end

          def index
            @gift_cards = Payment::GiftCard
                          .all
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

            respond_with gift_cards: @gift_cards
          end

          def create
            @gift_card = Payment::GiftCard.create!(params[:gift_card])
            respond_with(
              { gift_card: @gift_card },
              {
                status: :created,
                location: gift_card_path(@gift_card)
              }
            )
          end

          swagger_path '/gift_cards/{id}' do
            operation :get do
              key :summary, 'Find Gift card by ID'
              key :description, 'Returns a single gift card'
              key :operationId, 'showGiftCard'

              parameter do
                key :name, :id
                key :in, :path
                key :description, 'ID of gift card to fetch'
                key :required, true
                key :type, :string
              end

              response 200 do
                key :description, 'Gift card details'
                schema do
                  key :type, :object
                  property :gift_card do
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end

              response 404 do
                key :description, 'Gift card not found'
                schema do
                  key :type, :object
                  property :problem do
                    key :type, :string
                  end
                  property :params do
                    key :type, :object
                    key :additionalProperties, true
                  end
                end
              end
            end

            operation :patch do
              key :summary, 'Update a GiftCard'
              key :description, 'Updates attributes on a gift card'
              key :operationId, 'updateGiftCard'

              parameter do
                key :name, :id
                key :in, :path
                key :description, 'ID of gift card to update'
                key :required, true
                key :type, :string
              end

              parameter do
                key :name, :body
                key :in, :body
                key :required, true
                schema do
                  key :type, :object
                  property :gift_card do
                    key :description, 'New attributes'
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end

              response 204 do
                key :description, 'Gift card updated successfully'
              end

              response 422 do
                key :description, 'Validation failure'
                schema do
                  key :type, :object
                  property :problem do
                    key :type, :string
                  end
                  property :document do
                    key :'$ref', 'Workarea::Payment::GiftCard'
                  end
                end
              end

              response 404 do
                key :description, 'Gift card not found'
                schema do
                  key :type, :object
                  property :problem do
                    key :type, :string
                  end
                  property :params do
                    key :type, :object
                    key :additionalProperties, true
                  end
                end
              end
            end

            operation :delete do
              key :summary, 'Remove a Gift card'
              key :description, 'Remove a gift card'
              key :operationId, 'removeGiftCard'

              parameter do
                key :name, :id
                key :in, :path
                key :description, 'ID of gift card to remove'
                key :required, true
                key :type, :string
              end

              response 204 do
                key :description, 'Gift card removed successfully'
              end

              response 404 do
                key :description, 'Gift card not found'
                schema do
                  key :type, :object
                  property :problem do
                    key :type, :string
                  end
                  property :params do
                    key :type, :object
                    key :additionalProperties, true
                  end
                end
              end
            end
          end

          def show
            respond_with gift_card: @gift_card
          end

          def update
            @gift_card.update_attributes!(params[:gift_card])
            respond_with gift_card: @gift_card
          end

          def destroy
            @gift_card.destroy
            head :no_content
          end

          swagger_path '/gift_cards/bulk' do
            operation :patch do
              key :summary, 'Bulk Upsert Gift cards'
              key :description, 'Creates new gift cards or updates existing ones in bulk.'
              key :operationId, 'upsertGiftCards'
              key :produces, ['application/json']

              parameter do
                key :name, :body
                key :in, :body
                key :description, 'Array of gift cards to upsert'
                key :required, true
                schema do
                  key :type, :object
                  property :gift_cards do
                    key :type, :array
                    items do
                      key :'$ref', 'Workarea::Payment::GiftCard'
                    end
                  end
                end
              end

              response 204 do
                key :description, 'Upsert received'
              end
            end
          end

          def bulk
            @bulk = Api::Admin::BulkUpsert.create!(
              klass: Payment::GiftCard,
              data: params[:gift_cards].map(&:to_h)
            )

            head :no_content
          end

          private

          def find_gift_card
            @gift_card = Payment::GiftCard.find(params[:id])
          end
        end
      end
    end
  end
end
