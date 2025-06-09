/*
  # Update customer_requests table to include order_more option

  1. Changes
    - Update the check constraint to include 'order_more' as a valid request type
    - This allows customers to request ordering more food

  2. Security
    - Maintains existing RLS policies
*/

-- Drop the existing constraint
ALTER TABLE customer_requests DROP CONSTRAINT IF EXISTS customer_requests_request_type_check;

-- Add the updated constraint with order_more option
ALTER TABLE customer_requests ADD CONSTRAINT customer_requests_request_type_check 
  CHECK (request_type IN ('water', 'bill', 'order_more'));