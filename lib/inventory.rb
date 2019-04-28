class Inventory

  class OutOfStockError < StandardError
    def initialize(message)
      super(message)
    end
  end

  attr_accessor :inventory
  def initialize
    @inventory = {
      skis: 0,
      shovel: 0,
      sled: 0,
      snowblower: 0,
      tires: 0
    }
    @current_date = nil
  end

  def apply_inventory_restock(restock_event)
    @inventory[restock_event.item_stocked.to_sym] += restock_event.item_quantity.to_i
  end

  def apply_order(order_event)
    @inventory[order_event.item_ordered.to_sym] -= order_event.quantity.to_i

    if @inventory[order_event.item_ordered.to_sym] < 0
      raise OutOfStockError.new("Order item #{order_event.order_id} cannot be processed. #{@inventory[order_event.item_ordered.to_sym].abs} additonal #{order_event.item_ordered} required. Date of out of stock error is #{order_event.date}")
    end
  end
end
