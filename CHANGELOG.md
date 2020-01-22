Workarea Gift Cards 3.4.9 (2020-01-21)
--------------------------------------------------------------------------------

*   Fix Tests for 2020

    Update all tests so that they no longer depend on the year 2020 as an
    expiration year. Instead, use the  method provided by Workarea.

    GIFTCARDS-6
    Tom Scott



Workarea Gift Cards 3.4.7 (2019-09-04)
--------------------------------------------------------------------------------

*   Always Use Configured Currency For Default Values (#1)

    When specifying a `default:` for a Mongoid `Money` field, use an Integer
    type like `0` instead of converting it to a Money type, as this will get
    evaluated at compile-time rather than at runtime. Doing so preserves
    the currency configuration specified by the application at runtime.


Workarea Gift Cards 3.4.6 (2019-08-21)
--------------------------------------------------------------------------------

*   Open Source!



Workarea Gift Cards 3.4.5 (2019-03-05)
--------------------------------------------------------------------------------

*   Create Gift Cards For Order When Creating Fulfillment

    Workarea previously enqueued the `Workarea::CreateOrderedGiftCards`
    worker when an order was placed, but this caused an error if the job was
    executed prior to the fulfillment being persisted. This job will now
    enqueue after creating a new `Workarea::Fulfillment` record, ensuring
    that the data the worker needs is in place before it runs.

    GIFTCARDS-122
    Tom Scott

*   Fix Gift Cards Overwriting "To:" Field Translation

    Installing the gift cards plugin previously overrode the base
    `workarea.admin.fields.to` translation with "Recipient: ".
    This translation is now named to `workarea.admin.fields.recipient`,
    in order to preserve the text of `workarea.admin.fields.to` for other
    uses in the admin.

    GIFTCARDS-126
    Tom Scott

*   Add product-details__heading class for direct styling hook

    ECOMMERCE-6363
    Curt Howard



Workarea Gift Cards 3.4.4 (2019-02-05)
--------------------------------------------------------------------------------

*   Update for workarea v3.4 compatibility

    GIFTCARDS-123
    Matt Duffy



Workarea Gift Cards 3.4.3 (2019-01-22)
--------------------------------------------------------------------------------

*   Add #scroll to AdminRedemptionExport class to support large exports

    Matt Duffy

*   Incorrect Gift Card Timeline Link URL

    The URL to the gift card on the timeline when created is not correct,
    seems to be a bad copy/paste from the products. This link is now
    correctly pointing to the gift card's payment page, not a product page
    that doesn't exist.

    GIFTCARDS-104
    Tom Scott



Workarea Gift Cards 3.4.2 (2019-01-08)
--------------------------------------------------------------------------------

*   Update README

    GIFTCARDS-121
    Matt Duffy



Workarea Gift Cards 3.4.1 (2018-09-05)
--------------------------------------------------------------------------------

*   Gift Card Balance Can Equal Tendered Amount

    When a gift card is in use on an order, Workarea did not detect that it
    would cover the order total if the balance of the gift card was equal
    to the tendered amount. Change the `>` to a `>=` to ensure that gift
    cards with the exact amount as the order total will still be accounted
    for in checkout.

    GIFTCARDS-119
    Tom Scott



Workarea Gift Cards 3.4.0 (2018-05-24)
--------------------------------------------------------------------------------

*   Support Bulk Action Items UI

    ECOMMERCE-6012
    Curt Howard

*   Update exporting to work with v3.3.0 DataFile::Export

    GIFTCARDS-117
    Matt Duffy

*   Leverage Workarea Changelog task

    ECOMMERCE-5355
    Curt Howard

*   Update Mailers for Premailer

    GIFTCARDS-116
    Curt Howard

*   Make Gift Card an optional field

    GIFTCARDS-115
    Curt Howard



Workarea Gift Cards 3.3.0 (2018-02-06)
--------------------------------------------------------------------------------

*   Supportive updates for v3.2 Order Summary changes

    GIFTCARDS-113
    Curt Howard

*   Include shipping in pricing request

    When re-pricing the order to apply gift card deductions, pass the
    `Shipping` for this corresponding `Order` so that setting the gift card
    tender amount factors in the shipping total along with the items
    subtotal.

    GIFTCARDS-94
    Tom Scott

*   Convert index cards into table

    GIFTCARDS-110
    Curt Howard


Workarea Gift Cards 3.2.1 (2017-10-31)
--------------------------------------------------------------------------------

*   Prevent errors when API isn't installed

    Add condition to documentation test to check for API before requiring documentation test

    GIFTCARDS-111
    Jake Beresford


Workarea Gift Cards 3.2.0 (2017-10-17)
--------------------------------------------------------------------------------

*   Add crud endpoints for payment gift cards in admin api

    GIFTCARDS-109
    Francisco Galarza

Workarea Gift Cards 3.1.0 (2017-09-15)
--------------------------------------------------------------------------------

*   Rework gift card fulfillment tie in

    GIFTCARDS-106
    Matt Duffy

*   Update order fulfillment upon creation of Payment::GiftCard

    GIFTCARDS-106
    Matt Duffy

*   Add storefront API support (if it's installed)

    Includes endpoints for checking gift card balance, paying with a gift
    card, and tender display support.

    GIFTCARDS-102
    Ben Crouse

*   Update activity for trash restore link helper

    GIFTCARDS-101
    Matt Duffy

*   Add restore link to gift card admin activity

    GIFTCARDS-101
    Matt Duffy

*   Add jump to navigation config to plugin

    GIFTCARDS-100
    Dave Barnow


Workarea Gift Cards 3.0.2 (2017-08-22)
--------------------------------------------------------------------------------

*   Use token for gift card name on activity after card is deleted

    GIFTCARDS-103
    Matt Duffy


Workarea Gift Cards 3.0.1 (2017-07-25)
--------------------------------------------------------------------------------

*   Add jump to navigation config to plugin

    GIFTCARDS-100
    Dave Barnow


Workarea Gift Cards 3.0.0 (2017-05-26)
--------------------------------------------------------------------------------

*   Update for v3 compatibility

    GIFTCARDS-95
    Matt Duffy


WebLinc Gift Cards 2.1.1 (2017-03-01)
--------------------------------------------------------------------------------

*   Update giftcard mailer translation to render link correctly when passed as html

    GIFTCARDS-91
    Beresford, Jake

*   Add a maler preview for gift cards mailer.

    GIFTCARDS-90
    Beresford, Jake


WebLinc Gift Cards 2.1.0 (2016-10-12)
--------------------------------------------------------------------------------

*   Add activity support for v2.3

    GIFTCARDS-88
    Ben Crouse

*   Update product-prices markup to match generic

    Clean up call to pricing partial

    GIFTCARDS-84
    Kristen Ward


WebLinc Gift Cards 2.0.4 (2016-07-06)
--------------------------------------------------------------------------------

*   Update product-prices markup to match generic

    Clean up call to pricing partial

    GIFTCARDS-84
    Kristen Ward


WebLinc Gift Cards 2.0.3 (2016-04-26)
--------------------------------------------------------------------------------

*   Add reset results button to gift card redemptions page

    After applying date filters, there is no quick way to reset them.
    Add action button consistent with other admin pages.

    GIFTCARDS-78
    Kristen Ward


WebLinc Gift Cards 2.0.2 (2016-04-04)
--------------------------------------------------------------------------------


WebLinc Gift Cards 2.0.1 (2016-03-22)
--------------------------------------------------------------------------------

*   Ensure credit card is not added to payment if not necessary

    GIFTCARDS-73
    Matt Duffy



WebLinc Gift Cards 2.0.0 (January 26, 2016)
--------------------------------------------------------------------------------

*   Update add to cart form to use drawer, add analytics

    GIFTCARDS-79

*   Rename tender-related Gift Card methods

    Resolve a conflict between methods around order pricing during
    checkout and final amounts displayed on order summaries wihtin the
    store front.

    GIFTCARDS-77


WebLinc Gift Cards 1.0.0 (January 14, 2016)
--------------------------------------------------------------------------------

*   Improve misleading verbiage in checkout messaging

    The balance indicates current balance, not balance after the order
    has been placed.

    GIFTCARDS-76

*   Update date range pickers to current

    Replace in gift card and redemption index

    Update start/end date search parameters to be consistent with base

    Update tests

    GIFTCARDS-75

*   Add form submitting control to has balance dropdown

    GIFTCARDS-75

*   Update for compatibility with WebLinc 2.0

*   Replace absolute URLs with relative paths


WebLinc Gift Cards 0.11.0 (October 6, 2015)
--------------------------------------------------------------------------------

*   Add metadata to the edit view

    GIFTCARDS-69

*   Update plugin to be compatible with v0.12

    Update new & edit views, property work
    Add blank row to permissions partial
    Update indexes, add context-menu to summary/edit

    GIFTCARDS-69

*   Fix typo in sort menu options

    s/Redeeed/Redeemed in app/models/workarea/payment/gift_card/redemption.rb

    GIFTCARDS-72

*   Update plugin to be compatible with v0.12

    Update new & edit views, property work
    Add blank row to permissions partial
    Update indexes, add context-menu to summary/edit

    GIFTCARDS-69

*   Update menu classes for compatibility with WebLinc v0.12 (ECOMMERCE-1344)

    GIFTCARDS-64

*   Update for compatibility with the WebLinc v0.12 Ruby API.

    ECOMMERCE-1543


WebLinc Gift Cards 0.10.0 (August 21, 2015)
--------------------------------------------------------------------------------

*   Rename SCSS blocks `panel` and `panel--buttons` to `index-filters` and
    `form-actions`, respectively, for compatibility with WebLinc 0.11.

    4b4b284a2aa93f4aa1ce60333f3cbabe8f8e4ed7


WebLinc Gift Cards 0.9.0 (July 11, 2015)
--------------------------------------------------------------------------------

*   Add model summaries to index.

    GIFTCARDS-57

    21042f498aa5ef9bf9bf5937b89f6c95e0303185 (merge)

*   Remove view `workarea/storefront/orders/tenders/_gift_card.json.jbuilder`,
    which isn't used.

    679cabac2411dd4d0039ffbb25b564df13af7382

*   Update for compatibility with workarea 0.10.0.

    38055d2486d57d28164da779a4d8763cac727e76
    c1528cd6098bf565005dad94a7b62adeaecaa447
    18822a95254a6d475be7aee7fbd59743a4847be4
    618b4512d03a13b3a063e3faf70254b4c57baeeb
    74f4ad180bc5f17883ff987a336235d99737daa6
    c78cd1aa7a9e2edb4a6867cb7ab0e149f1d64e2e
    d4e2ea1a5e334df9f1f83849ec8b263539456fd9

*   Fix "back" links in Admin.

    GIFTCARDS-61

    fc80b8a6428e478e0f21d256a91fe9a89354dfdc

*   Fix `selected_navigation_nodes` in Admin.

    GIFTCARDS-60

    405446c3a63700bd20a2efac4b934c35f9fd3e9e

*   Remove quantity field from gift card template.

    GIFTCARDS-44

    c554279546f896e1973993c54d139efeda91944b


WebLinc Gift Cards 0.8.0 (June 1, 2015)
--------------------------------------------------------------------------------

*   Rename fixtures to factories and clean up factories.

    dae3b82cbdb54ba988bc1804ba332c614c21016d

*   Refactor listeners.

    ea96c63c536d3b922c0b05e1ab4e843a8bc9a6eb

*   Update for compatibility with workarea 0.9.0.

    faf0721baaee7431c7c1825576b68574acbf137b

    GIFTCARDS-56

*   Allow both strings and symbols as keys in params hash of gift card search.

    GIFTCARDS-54

*   Move gift cards API functionality from workarea-gift_cards to workarea-api.

    GIFTCARDS-50


WebLinc Gift Cards 0.7.0 (April 10, 2015)
--------------------------------------------------------------------------------

*   Allow "From" to be a value other than an email address.

    The "From" field for gift cards was required to be an email address, but users were entering non-email values such as "Mom & Dad". This change removes the email validation from the model.

    GIFTCARDS-51

*   Update JavaScript modules for compatibility with WebLinc 0.8.0.

*   Update testing environment for compatibility with WebLinc 0.8.0.

*   Move product description out of add to cart form for consistency with WebLinc 0.8.0.

    GIFTCARDS-36

*   Use new decorator style for consistency with WebLinc 0.8.0.

*   Remove gems server secrets for consistency with WebLinc 0.8.0.

*   Remove `money_field` method for compatibility with WebLinc 0.8.0.

    GIFTCARDS-43

*   Update assets for compatibility with WebLinc 0.8.0.
