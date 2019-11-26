Workarea Gift Cards
================================================================================

A Workarea Commerce plugin that enables customers to purchase physical and digital gift cards and redeem them for other merchandise within the catalog.

Overview
--------------------------------------------------------------------------------

* Create gift card products, both digital and physical
* Allow gift card customization with recipient name, email, and personal message
* Automatically deliver digital gift card information to recipient upon purchase
* Use any number of gift cards as payment in checkout (with configurable limit)
* Check the balance of a digital gift card
* Manage digital gift cards from the admin
* View gift card redemptions from the admin
* Admin API management of gift cards
* Storefront API support for using gift cards in checkout
* Gateway support for easily using a third-party gift card service (see below)

Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile:

```ruby
# ...
gem 'workarea-gift_cards'
# ...
```

Update your application's bundle.

```bash
cd path/to/application
bundle
```

Using a custom gift card gateway
--------------------------------------------------------------------------------

The `workarea-gift_cards` plugin comes fully functional with management of gift cards, tracking of redemptions and balances within the Workarea admin. However, using a third-party gift card service is not uncommon. Taking that into consideration, the plugin allows for the use of a custom gateway for looking up
balances, validating gift card info, and processing gift card payments. This allows a retailer to utilize the plugin for the gift card product behaviors, but continue using a third-party service for generating gift card codes and tracking the use of purchased gift cards.

## Setup a custom gateway

The plugin adds a configuration value of `Workarea.config.gateways.gift_card`. By default, this is set to `Workarea::GiftCards::Gateway`, which utilizes the existing `Workarea::Payment::GiftCard` collection. This configuration value can be changed to a custom class of your choice that responds to the same methods.

```ruby
class ThirdPartyGiftCardGateway
  # setup any relevant configuration required for connecting to a
  # third-party service
  #
  def initialize; end

  # Optional. Define this method to tell the system you are using the
  # Workarea::Payment::GiftCard collection. This will turn on a number of
  # behaviors only relevant when using the collection. If the gateway does not
  # respond to this method, it will assume false.
  #
  def uses_system_cards?
    true
  end

  # These are the transactional methods expected from the gateway. They each
  # take two arguments:
  #   amount - is the value (in cents) that transaction is looking to apply.
  #   tender - will be a Workarea::Payment::Tender::GiftCard which you can use
  #            to find the relevant card number or other info stored on the
  #            tender associated to this transaction.
  #
  # The system expects these method to return an object that responds to
  # two methods:
  #   success? - a boolean that determines if the transaction was successful
  #   message - information around the transaction result
  #
  def authorize(amount, tender); end
  def cancel(amount, tender); end
  def capture(amount, tender); end
  def purchase(amount, tender); end
  def refund(amount, tender); end

  # This passes in one or more tokens/numbers as strings and returns a Money
  # object that represents the total balance of all valid card numbers.
  #
  def balance(token); end

  # This method is used when a customer looks up their balance from the
  # storefront. This will often require them to provide some unique info
  # to protect against malicious attempts at discovering gift card numbers.
  # The request parameters are passed directly into the method to allow
  # flexibility in the information you request from the user to show them
  # the balance. By default, the system expects this method to return an
  # object that responds to #balance, #token, and #to. This is entirely
  # dependent on the resulting view rendered, which can be customized.
  #
  def lookup(params); end
end
```

After building a custom class, set the config value to the custom class.

```ruby
Workarea.configure do |config|
  config.gateways.gift_card = 'ThirdPartyGiftCardGateway'
end
```

Note that it is set to a string of the class constant, and not an instance of the class. The system constantizes and initializes a new instance whenever it uses the gateway to ensure autoloading works correctly and so a gateway that cares about the current state of the application is applied correctly. This is most relevant in multi-site environments where each site might want to use their own gift card gateway.


Workarea Commerce Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea Commerce documentation

License
--------------------------------------------------------------------------------

Workarea Gift Cards is released under the [Business Software License](LICENSE)
