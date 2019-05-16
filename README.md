# inventory_checker

Assumptions: I assumed that the restock events and order events were in the same time zone because no information was provided on the orders time zone. I assume that inventory could not go below zero so that if an order was placed that would cause the inventory for that item to go below zero at that moment, it would create an `OutOfStockError`. However, in reality, there may be slightly more room for a fudge factor -- for example, a company might know an order is being delivered the following morning and so the order shouldn't actually be canceled. The code could be updated to allow, for example, a 24-hour waiting period to see if more inventory would arrive before generating an `OutOfStockError`.

For the restock and order events, I originally toyed with having essentially 2 queues, one for restock and one for order (where the events are already sorted by time), and comparing the first item from each queue to see which was next. However while saving some space, this proved more error prone and harder to debug, so I ultimately concatenated the 2 together and resorted. This took some additional time and space, but the code is easier to follow and as items are `.shift` off of the queue the original input data is maintained and not mutated due to the copy.

### Installation
Run `bundle install`

### To Run Program
`bin/inventory_checker <restock-file> <orders-file>`

For example: `bin/inventorychecker data/restocks.json data/orders.json`

### Tests
To run tests run `rspec spec`
