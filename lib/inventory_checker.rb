require 'json'
require_relative 'inventory'
require_relative 'restock'
require_relative 'order'

class InventoryChecker

  def initialize
    restock_json = convert_to_json(ARGV[0])
    order_json = convert_to_json(ARGV[1])

    @restock_events = generate_restock_events(restock_json)
    @order_events = generate_order_events(order_json)
    @current_inventory = Inventory.new
  end

  def generate_restock_events(restock_json)
    restock_events = []
    restock_json.each do |restock_event|
      restock_events << Restock.new(restock_event)
    end
    return restock_events.sort_by { |event| event.date }
  end

  def generate_order_events(order_json)
    order_events = []
    order_json.each do |order_event|
      order_events << Order.new(order_event)
    end
    return order_events.sort_by { |event| event.date }
  end

  def convert_to_json(file)
    raise "Error: File #{file} is empty" if File.empty?(file)

    parsed_json = JSON.parse(File.read(file))

    rescue JSON::ParserError => e
      raise "#{file} is invalid JSON and cannot be parsed #{e}"
    return parsed_json
  end

  def run

    begin
      until @order_events.empty? || @restock_events.empty?
        next_order = @order_events.shift
        next_restock = @restock_events.shift
        if next_order.date < next_restock.date
          @current_inventory.apply_order(next_order)
        else
          @current_inventory.apply_inventory_restock(next_restock)
        end
      end

      until @order_events.empty?
        next_order = @order_events.shift
        @current_inventory.apply_order(next_order)
      end

      until @restock_events.empty?
        next_restock = @restock_events.shift
        @current_inventory.apply_inventory_restock
      end

    rescue Inventory::OutOfStockError => e
      puts "out_of_stock: #{e}"
      return
    end

    puts "success: #{@current_inventory}"
    return
  end
  # sample return value
#   { success: {
#     shovel: 4,
      # sled: 1,
      # snowblower: 4,
      # tires: 2
#     }
#   }
end
