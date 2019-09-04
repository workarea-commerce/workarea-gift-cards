module Workarea
  class Payment
    class GiftCard
      include ApplicationDocument
      include Commentable

      field :token, type: String
      field :to, type: String
      field :from, type: String
      field :message, type: String
      field :expires_at, type: DateTime
      field :notify, type: Boolean
      field :purchased, type: Boolean

      # Order id if this card was created
      # by a customer purchasing it.
      field :order_id, type: String

      field :amount, type: Money, default: 0
      field :used, type: Money, default: 0
      field :balance, type: Money, default: 0

      has_many :redemptions, class_name: 'Workarea::Payment::GiftCard::Redemption'

      index({ token: 1 }, { unique: true })
      index(to: 1)
      index('balance.cents' => 1)
      index(expires_at: 1)
      index(created_at: 1)

      alias_method :number, :token

      validates :token, presence: true
      validates :amount, presence: true
      validates :to, email: true

      scope :not_expired, -> {
        any_of({ :expires_at.exists => false },
               { expires_at: nil },
               { :expires_at.gte => Time.now })
      }

      before_validation :assign_token

      # Sorts available for this class.
      #
      # @return [Array<Workarea::Sort>]
      #
      def self.sorts
        [Workarea::Sort.newest, Workarea::Sort.modified]
      end

      # Find gift cards whose token or recipient matches the
      # given string. Used in admin filtering.
      #
      # @param [String]
      # @return [Mongoid::Criteria]
      #
      def self.search_by_token_or_recipient(string)
        regex = /^#{::Regexp.quote(string)}/i
        any_of({ token: regex }, { to: regex })
      end

      # Performs purchase of the gift card that matches the given token.
      # Purchase is for the amount in cents.
      #
      # @param [String] token Representing Payment::GiftCard#token
      # @param [Integer] cents Amount of purchase
      # @return [Payment::GiftCard]
      #
      def self.purchase(token, cents)
        not_expired.find_by_token(token).purchase(cents)
      end

      # Performs refund of the gift card that matches the given token.
      # Refund is for the amount in cents.
      #
      # @param [String] token Representing Payment::GiftCard#token
      # @param [Integer] cents Amount to refund
      # @return [Payment::GiftCard]
      #
      def self.refund(token, cents)
        find_by_token(token).refund(cents)
      end

      # Gift card balance for the given token. If the Gift card does
      # not exist, $0 is returned.
      #
      # @param [String] token Representing Payment::GiftCard#token
      # @return [Money]
      #
      def self.find_balance(token)
        card = not_expired.find_by_token(token)
        card ? card.balance : 0.to_m
      end

      def self.find_by_token(token)
        where(token: token.downcase).first
      end

      def self.find_by_token_and_email(token, email)
        where(token: token, to: email.downcase).not_expired.first
      end

      def to=(val)
        if val.nil?
          super(val)
        else
          super(val.to_s.downcase)
        end
      end

      def valid?(*)
        super.tap do |result|
          self.balance = amount if result && !persisted?
          self.token = token.downcase if token.present?
        end
      end

      # This is for compatibility with the admin, all models must implement this
      #
      # @return [String]
      #
      def name
        I18n.t('workarea.payment_gift_card.name', token: token)
      end

      # Whether the gift card has expired.
      #
      # @return [Boolean]
      #
      def expired?
        !!(expires_at && Time.now >= expires_at)
      end

      # The date of the last redemption.
      #
      # @return [DateTime]
      #
      def last_redeemed_at
        redemptions.asc(:redeemed_at).last.try(:redeemed_at)
      end

      # Performs purchase for the amount in cents.
      #
      # @param [Integer] cents Amount of purchase
      # @return [Payment::GiftCard]
      #
      # @raise [Payment::InsufficientFunds]
      #   the balance of the gift card does not cover the cents
      #
      def purchase(cents)
        raise(Workarea::Payment::InsufficientFunds) if balance.cents < cents
        inc('balance.cents' => 0 - cents, 'used.cents' => cents)
        self
      end

      # Performs refund for the amount in cents.
      #
      # @param [Integer] cents Amount of purchase
      # @return [Payment::GiftCard]
      #
      def refund(cents)
        inc('balance.cents' => cents, 'used.cents' => 0 - cents)
        self
      end

      def reset_token!
        update_attribute(:token, generate_token)
      end

      def generate_token
        loop do
          tmp = SecureRandom.hex(Workarea.config.gift_card_token_length / 2).downcase
          break tmp unless self.class.where(token: tmp).exists?
        end
      end

      private

      def assign_token
        self.token = generate_token if token.blank?
      end
    end
  end
end
