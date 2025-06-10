-- Enable realtime for orders table
alter publication supabase_realtime add table orders;

-- Enable row level security for orders table
alter table orders enable row level security;

-- Create policy for customers to see their own orders
create policy "Customers can view their own orders"
  on orders
  for select
  using (table_number::text = (select table_number::text from device_sessions where device_id = current_setting('request.jwt.claims')::json->>'sub'));

-- Create policy for staff to manage all orders
create policy "Staff can view and update all orders"
  on orders
  for all
  using (
    auth.role() = 'authenticated' and 
    exists (
      select 1 from profiles 
      where id = auth.uid() 
      and role in ('manager', 'servant')
    )
  );
