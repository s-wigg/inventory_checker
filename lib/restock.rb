require 'time'

class Restock

  attr_reader :date, :item_stocked, :item_quantity, :manufacturer, :wholesale_price
  def initialize(restock_event)
    @date = Time.parse(restock_event["restock_date"])
    @item_stocked = restock_event["item_stocked"]
    @item_quantity = restock_event["item_quantity"]
    @manufacturer = restock_event["manufacturer"]
    @wholesale_price = restock_event["wholesale_price"]
  end

end
