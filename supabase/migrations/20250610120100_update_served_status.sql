-- Update existing orders with 'served' status to 'order is ready'
UPDATE orders
SET status = 'order is ready'
WHERE status = 'served';

-- Update the check constraint for order status
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'preparing', 'order is ready', 'cancelled'));
