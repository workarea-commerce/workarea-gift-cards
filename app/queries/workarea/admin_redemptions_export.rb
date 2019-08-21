# Query class for models to match the API of {Search::Query}.
#
# HOLY SHIT THIS HOT MESS SHOULD BE SOLVED DIFFERENTLY AT SOME POINT
#
module Workarea
  class AdminRedemptionsExport
    include Search::Pagination
    include GlobalID::Identification

    attr_reader :params, :gift_cards_query_id
    alias_method :id, :gift_cards_query_id

    def self.find(id)
      new(gift_cards_query_id: id)
    end

    def initialize(params = {})
      @params = params.with_indifferent_access
      @gift_cards_query_id = params[:gift_cards_query_id]
    end

    def results
      @results ||= PagedArray.new(
        redemptions_for(gift_card_ids).to_a,
        page,
        per_page,
        gift_cards_query.total # ensure correct paginating
      )
    end

    def scroll(options = {}, &block) # to match Search::Query method arguments
      results.total_pages.times do |page|
        query = self.class.new(params.merge(page: page + 1))
        yield query.results
      end
    end

    def total
      @total ||= begin
        result = 0

        gift_cards_query.results.total_pages.times do |page|
          page_params = gift_cards_query.params.merge(page: page + 1)
          page_query = gift_cards_query.class.new(page_params)
          page_query.define_singleton_method(:per_page) { Workarea.config.bulk_action_per_page }
          result += redemptions_for(page_query.results.map(&:id)).count
        end

        result
      end
    end

    private

    def per_page
      Workarea.config.bulk_action_per_page
    end

    def redemptions_for(ids)
      Payment::GiftCard::Redemption.in(gift_card_id: ids)
    end

    def gift_cards_page
      params[:page].present? ? params[:page].to_i : 1
    end

    def gift_cards_query
      @gift_cards_query ||= begin
        result = GlobalID.find(gift_cards_query_id)
        page_for_query = gift_cards_page
        result.define_singleton_method(:page) { page_for_query }
        result
      end
    end

    def gift_card_ids
      gift_cards_query.results.map(&:id) - exclude_gift_card_ids
    end

    def exclude_gift_card_ids
      GlobalID::Locator.locate_many(Array.wrap(params[:exclude_ids])).map(&:id)
    end
  end
end
