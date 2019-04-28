require 'json'
require_relative 'inventory'
require_relative 'restock'
require_relative 'order'

class InventoryChecker

  def initialize
    restock_json = convert_to_json(ARGV[0])
    order_json = convert_to_json(ARGV[1])

    @restock_events = create_events(restock_json, "Restock")
    @order_events = create_events(order_json, "Order")
    @current_inventory = Inventory.new
  end

  def create_events(input, type)
    events = []
    klass = Object.const_get(type)
    input.each do |obj|
      events << klass.new(obj)
    end
    return events.sort_by { |event| event.date }
  end

  def convert_to_json(file)
    raise "Error: File #{file} is empty" if File.empty?(file)

    parsed_json = JSON.parse(File.read(file))

  rescue JSON::ParserError => e
    raise "#{file} is invalid JSON and cannot be parsed #{e}"
    return parsed_json
  end

  def run
    combined_events = @order_events.concat(@restock_events).sort_by { |event| event.date }

    # uncomment puts statements for debugging purposes
    begin
      until combined_events.empty?

        next_event = combined_events.shift
        if next_event.class == Restock
          # puts "applying next stock quantity #{next_event.item_quantity} for item #{next_event.item_stocked} for date #{next_event.date}"
          @current_inventory.apply_inventory_restock(next_event)
        elsif next_event.class == Order
          # puts "applying next order #{next_event.quantity} for item #{next_event.item_ordered} for date #{next_event.date}"
          @current_inventory.apply_order(next_event)
        end
      end
    rescue Inventory::OutOfStockError => e
      puts "OUT OF STOCK: #{e}"
      return
    end
    puts "SUCCESS"
    @current_inventory.print_inventory
    return
  end
end
