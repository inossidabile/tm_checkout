# TmCheckout

To be used as: 

```ruby
cart = TmCheckout::Calculator.new do
  # Prices with quantity discounts
  fr1 3.11
  ap1 5.00, 3 => 4.50
  cf1 11.23

  # The list of products for buy 1 get 1 free action
  ___ fr1
end

cart.scan :fr1
cart.scan 'FR1'
cart.scan :AP1

cart.calculate
```