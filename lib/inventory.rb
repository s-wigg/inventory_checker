class Inventory

  class OutOfStockError < StandardError
    def initialize(message)
      super(message)
    end
  end

  attr_accessor :inventory
  def initialize
    @inventory = {
      skis: [],
      shovel: [],
      sled: [],
      snowblower: [],
      tires: []
    }
    @current_date = nil
  end

  def apply_inventory_restock(restock_event)
    @inventory[restock_event.item_stocked.to_sym] << { quantity: restock_event.item_quantity, price: restock_event.wholesale_price.to_f }
  end

  def apply_order(order_event)
    total_proceeds = order_event.quantity.to_i * order_event.item_price.to_f
    total_cost = 0
    quantity_needed = order_event.quantity.to_i

    while quantity_needed > 0
      if @inventory[order_event.item_ordered.to_sym].empty?
        raise OutOfStockError.new("Order item #{order_event.order_id} cannot be processed. #{@inventory[order_event.item_ordered.to_sym].abs} additional #{order_event.item_ordered} required. Date of out of stock error is #{order_event.date}")
      end

      current_inventory = @inventory[order_event.item_ordered.to_sym].shift

      quantity = current_inventory[:quantity]

      if quantity >= quantity_needed

        new_quantity = quantity - quantity_needed

        total_cost += (quantity_needed * current_inventory[:price])

        current_inventory[:quantity] = new_quantity

        if new_quantity > 0
          @inventory[order_event.item_ordered.to_sym].unshift(current_inventory
        )
        end
        quantity_needed = 0

      else
        quantity_needed -= quantity

        total_cost += (quantity * current_inventory[:price])
      end
    end

    return total_proceeds - total_cost
  end

  def print_inventory
    @inventory.each do |item, quantity|
      puts "#{item}: #{quantity}"
    end
  end
end
