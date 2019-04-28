require 'inventory'
require 'order'
require 'restock'

describe Inventory do

  it "applies restock event to the inventory" do
    @current_inventory = Inventory.new
    expect(@current_inventory.inventory[:shovel]).to eq(0)
    restock = {
      "restock_date" => "2018-01-01T04:00:00Z",
      "item_stocked" => "shovel",
      "item_quantity" => "25",
      "manufacturer" => "Knightly Shovels",
      "wholesale_price" => " Inc."
    }

    restock_event = Restock.new(restock)
    @current_inventory.apply_inventory_restock(restock_event)
    expect(@current_inventory.inventory[:shovel]).to eq(25)
  end

  it "applies an order event to the inventory" do
    @current_inventory = Inventory.new

    restock = {
      "restock_date" => "2018-01-01T04:00:00Z",
      "item_stocked" => "sled",
      "item_quantity" => "7",
      "manufacturer" => "Knightly Shovels",
      "wholesale_price" => " Inc."
    }

    restock_event = Restock.new(restock)
    @current_inventory.apply_inventory_restock(restock_event)
    expect(@current_inventory.inventory[:sled]).to eq(7)

    order = {
      "order_id" => "630",
      "customer_id" => "4",
      "order_date" => "2018-03-09T13:13:29",
      "item_ordered" => "sled",
      "item_quantity" => "6",
      "item_price" => "96.93"
    }
    order_event = Order.new(order)
    @current_inventory.apply_order(order_event)
    expect(@current_inventory.inventory[:sled]).to eq(1)
  end

  it "raises an error if there is not inventory to meet the order" do
    @current_inventory = Inventory.new

    order = {
      "order_id" => "630",
      "customer_id" => "4",
      "order_date" => "2018-03-09T13:13:29",
      "item_ordered" => "sled",
      "item_quantity" => "6",
      "item_price" => "96.93"
    }
    order_event = Order.new(order)
    expect{@current_inventory.apply_order(order_event)}.to raise_error(Inventory::OutOfStockError, "Order item 630 cannot be processed. 6 additional sled required. Date of out of stock error is 2018-03-09 13:13:29 -0800")
  end
end
