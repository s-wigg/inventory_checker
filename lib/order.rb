require 'time'

class Order

  attr_reader :order_id, :customer_id, :date, :item_ordered, :item_price, :quantity

  def initialize(order)
    @order_id = order["order_id"]
    @customer_id = order["customer_id"]
    @date = Time.parse(order["order_date"])
    @item_ordered = order["item_ordered"]
    @item_price = order["item_price"]
    @quantity = order["item_quantity"]
  end
end
