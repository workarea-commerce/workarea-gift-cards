json.gift_card do
  json.complete step.complete?
  json.gift_card_balance summary.gift_card_balance
  json.gift_card_amount summary.gift_card_amount
  json.order_balance summary.order_balance
end
