module Workarea
  module Search
    class AdminGiftCards
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'gift_card'))
      end

      def facets
        super + [TermsFacet.new(self, 'created_by')]
      end
    end
  end
end
