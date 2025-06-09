/*
  # Food 'n' Fun Restaurant Database Schema

  1. New Tables
    - `menu_items`
      - `id` (uuid, primary key)
      - `title` (text, menu item name)
      - `description` (text, item description)
      - `price` (decimal, item price)
      - `prep_time` (integer, preparation time in minutes)
      - `category` (text, food category)
      - `image_url` (text, optional image)
      - `is_available` (boolean, availability status)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `tables`
      - `id` (integer, primary key)
      - `table_number` (integer, unique table identifier)
      - `status` (text, 'free' or 'occupied')
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `device_sessions`
      - `id` (uuid, primary key)
      - `table_id` (integer, foreign key to tables)
      - `device_id` (text, unique device identifier)
      - `created_at` (timestamp)

    - `orders`
      - `id` (uuid, primary key)
      - `table_id` (integer, foreign key to tables)
      - `device_id` (text, device that placed order)
      - `items` (jsonb, ordered items with quantities)
      - `total_amount` (decimal, total order value)
      - `max_prep_time` (integer, longest prep time)
      - `status` (text, 'pending', 'preparing', 'served')
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `customer_requests`
      - `id` (uuid, primary key)
      - `table_id` (integer, foreign key to tables)
      - `request_type` (text, 'water' or 'bill')
      - `is_served` (boolean, completion status)
      - `created_at` (timestamp)
      - `served_at` (timestamp, nullable)

  2. Security
    - Enable RLS on all tables
    - Add policies for different user roles
    - Manager and servant authentication via Supabase Auth
*/

-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  price decimal(10,2) NOT NULL,
  prep_time integer NOT NULL DEFAULT 15,
  category text NOT NULL,
  image_url text,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create tables table
CREATE TABLE IF NOT EXISTS tables (
  id integer PRIMARY KEY,
  table_number integer UNIQUE NOT NULL,
  status text NOT NULL DEFAULT 'free' CHECK (status IN ('free', 'occupied')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create device_sessions table
CREATE TABLE IF NOT EXISTS device_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_id integer REFERENCES tables(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(table_id, device_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_id integer REFERENCES tables(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  items jsonb NOT NULL,
  total_amount decimal(10,2) NOT NULL,
  max_prep_time integer NOT NULL DEFAULT 15,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'preparing', 'served')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create customer_requests table
CREATE TABLE IF NOT EXISTS customer_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_id integer REFERENCES tables(id) ON DELETE CASCADE,
  request_type text NOT NULL CHECK (request_type IN ('water', 'bill')),
  is_served boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  served_at timestamptz
);

-- Enable Row Level Security
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies for menu_items (readable by everyone, writable by authenticated users only)
CREATE POLICY "Menu items are viewable by everyone"
  ON menu_items FOR SELECT
  USING (true);

CREATE POLICY "Menu items are manageable by authenticated users"
  ON menu_items FOR ALL
  TO authenticated
  USING (true);

-- RLS Policies for tables (readable by everyone, writable by authenticated users only)
CREATE POLICY "Tables are viewable by everyone"
  ON tables FOR SELECT
  USING (true);

CREATE POLICY "Tables are manageable by authenticated users"
  ON tables FOR ALL
  TO authenticated
  USING (true);

-- RLS Policies for device_sessions (readable by everyone)
CREATE POLICY "Device sessions are viewable by everyone"
  ON device_sessions FOR SELECT
  USING (true);

CREATE POLICY "Device sessions are manageable by everyone"
  ON device_sessions FOR ALL
  USING (true);

-- RLS Policies for orders (readable by everyone, writable by everyone for customer orders)
CREATE POLICY "Orders are viewable by everyone"
  ON orders FOR SELECT
  USING (true);

CREATE POLICY "Orders are manageable by everyone"
  ON orders FOR ALL
  USING (true);

-- RLS Policies for customer_requests (readable by everyone, writable by everyone)
CREATE POLICY "Customer requests are viewable by everyone"
  ON customer_requests FOR SELECT
  USING (true);

CREATE POLICY "Customer requests are manageable by everyone"
  ON customer_requests FOR ALL
  USING (true);

-- Insert sample data
INSERT INTO menu_items (title, description, price, prep_time, category) VALUES
('Chicken Biryani', 'Aromatic basmati rice cooked with tender chicken and traditional spices', 250.00, 25, 'main'),
('Paneer Butter Masala', 'Creamy tomato-based curry with soft paneer cubes', 180.00, 15, 'main'),
('Veg Spring Rolls', 'Crispy rolls filled with fresh vegetables and served with sweet chili sauce', 120.00, 10, 'starter'),
('Chicken 65', 'Spicy fried chicken appetizer with curry leaves and green chilies', 160.00, 12, 'starter'),
('Mutton Curry', 'Traditional spicy mutton curry cooked with onions and aromatic spices', 300.00, 35, 'main'),
('Fish Fry', 'Fresh fish marinated with spices and shallow fried to perfection', 220.00, 15, 'main'),
('Veg Fried Rice', 'Wok-tossed rice with mixed vegetables and soy sauce', 140.00, 12, 'main'),
('Chicken Tikka', 'Grilled chicken pieces marinated in yogurt and spices', 200.00, 20, 'starter'),
('Masala Dosa', 'Crispy rice crepe filled with spiced potato mixture', 80.00, 8, 'main'),
('Gulab Jamun', 'Sweet milk dumplings soaked in sugar syrup', 60.00, 5, 'dessert');

-- Insert sample tables
INSERT INTO tables (id, table_number) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);