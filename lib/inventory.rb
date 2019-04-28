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

    # if the conditional below is commented out, then the whole program runs and returns the output specified in the instructions:
    #{:skis=>0, :shovel=>4, :sled=>1, :snowblower=>4, :tires=>2}
    # but otherwise I get the following error:
    # OUT OF STOCK: Order item 632 cannot be processed. 1 additonal sled required. Date of out of stock error is 2018-03-18 01:13:34 -0700
    if @inventory[order_event.item_ordered.to_sym] < 0
      raise OutOfStockError.new("Order item #{order_event.order_id} cannot be processed. #{@inventory[order_event.item_ordered.to_sym].abs} additional #{order_event.item_ordered} required. Date of out of stock error is #{order_event.date}")
    end
  end

  def print_inventory
    @inventory.each do |item, quantity|
      puts "#{item}: #{quantity}"
    end
  end
end
