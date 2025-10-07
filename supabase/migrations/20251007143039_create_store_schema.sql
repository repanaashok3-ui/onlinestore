/*
  # Create Online Store Schema

  1. New Tables
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `created_at` (timestamptz)
    
    - `products`
      - `id` (uuid, primary key)
      - `category_id` (uuid, foreign key to categories)
      - `name` (text)
      - `description` (text)
      - `price` (numeric)
      - `image_url` (text)
      - `stock` (integer)
      - `rating` (numeric)
      - `created_at` (timestamptz)
    
    - `cart_items`
      - `id` (uuid, primary key)
      - `session_id` (text) - for guest users
      - `product_id` (uuid, foreign key to products)
      - `quantity` (integer)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Public read access for categories and products (catalog browsing)
    - Public access for cart operations (guest shopping)

  3. Sample Data
    - Populate categories: Fruits, Mobiles, Electronics, Home & Kitchen, Fashion
    - Add diverse products across all categories
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  price numeric NOT NULL CHECK (price >= 0),
  image_url text NOT NULL,
  stock integer DEFAULT 0 CHECK (stock >= 0),
  rating numeric DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  created_at timestamptz DEFAULT now()
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  quantity integer DEFAULT 1 CHECK (quantity > 0),
  created_at timestamptz DEFAULT now(),
  UNIQUE(session_id, product_id)
);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Policies for categories (public read)
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (true);

-- Policies for products (public read)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  USING (true);

-- Policies for cart_items (public access for guest shopping)
CREATE POLICY "Anyone can view their cart"
  ON cart_items FOR SELECT
  USING (true);

CREATE POLICY "Anyone can add to cart"
  ON cart_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update cart"
  ON cart_items FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete from cart"
  ON cart_items FOR DELETE
  USING (true);

-- Insert categories
INSERT INTO categories (name, description) VALUES
  ('Fruits', 'Fresh and healthy fruits'),
  ('Mobiles', 'Latest smartphones and accessories'),
  ('Electronics', 'Electronic gadgets and devices'),
  ('Home & Kitchen', 'Essential home and kitchen items'),
  ('Fashion', 'Clothing and accessories')
ON CONFLICT (name) DO NOTHING;

-- Insert products
INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fruits'),
  'Fresh Apples',
  'Crisp and sweet red apples, perfect for snacking',
  4.99,
  'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=400',
  150,
  4.5
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Fresh Apples');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fruits'),
  'Organic Bananas',
  'Fresh organic bananas rich in potassium',
  3.49,
  'https://images.pexels.com/photos/61127/pexels-photo-61127.jpeg?auto=compress&cs=tinysrgb&w=400',
  200,
  4.7
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Organic Bananas');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fruits'),
  'Strawberries',
  'Sweet and juicy fresh strawberries',
  6.99,
  'https://images.pexels.com/photos/934066/pexels-photo-934066.jpeg?auto=compress&cs=tinysrgb&w=400',
  80,
  4.8
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Strawberries');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Mobiles'),
  'iPhone 15 Pro',
  'Latest iPhone with titanium design and A17 Pro chip',
  999.99,
  'https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400',
  45,
  4.9
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'iPhone 15 Pro');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Mobiles'),
  'Samsung Galaxy S24',
  'Premium Android smartphone with advanced camera',
  899.99,
  'https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg?auto=compress&cs=tinysrgb&w=400',
  60,
  4.7
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Samsung Galaxy S24');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Mobiles'),
  'Google Pixel 8',
  'AI-powered smartphone with exceptional photography',
  699.99,
  'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg?auto=compress&cs=tinysrgb&w=400',
  35,
  4.6
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Google Pixel 8');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Electronics'),
  'Wireless Headphones',
  'Premium noise-cancelling wireless headphones',
  199.99,
  'https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg?auto=compress&cs=tinysrgb&w=400',
  120,
  4.5
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wireless Headphones');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Electronics'),
  'Smart Watch',
  'Fitness tracking smartwatch with heart rate monitor',
  249.99,
  'https://images.pexels.com/photos/393047/pexels-photo-393047.jpeg?auto=compress&cs=tinysrgb&w=400',
  90,
  4.4
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Smart Watch');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Electronics'),
  'Bluetooth Speaker',
  'Portable waterproof bluetooth speaker',
  79.99,
  'https://images.pexels.com/photos/1279093/pexels-photo-1279093.jpeg?auto=compress&cs=tinysrgb&w=400',
  150,
  4.6
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bluetooth Speaker');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Home & Kitchen'),
  'Coffee Maker',
  'Programmable coffee maker with thermal carafe',
  89.99,
  'https://images.pexels.com/photos/324028/pexels-photo-324028.jpeg?auto=compress&cs=tinysrgb&w=400',
  75,
  4.3
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Coffee Maker');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Home & Kitchen'),
  'Blender',
  'High-speed blender for smoothies and more',
  69.99,
  'https://images.pexels.com/photos/4226894/pexels-photo-4226894.jpeg?auto=compress&cs=tinysrgb&w=400',
  65,
  4.4
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Blender');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Home & Kitchen'),
  'Air Fryer',
  'Healthy cooking with rapid air circulation technology',
  129.99,
  'https://images.pexels.com/photos/6419121/pexels-photo-6419121.jpeg?auto=compress&cs=tinysrgb&w=400',
  55,
  4.7
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Air Fryer');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fashion'),
  'Leather Jacket',
  'Premium genuine leather jacket',
  199.99,
  'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&cs=tinysrgb&w=400',
  40,
  4.5
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Leather Jacket');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fashion'),
  'Running Shoes',
  'Comfortable athletic shoes for running',
  89.99,
  'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=400',
  100,
  4.6
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Running Shoes');

INSERT INTO products (category_id, name, description, price, image_url, stock, rating)
SELECT 
  (SELECT id FROM categories WHERE name = 'Fashion'),
  'Designer Sunglasses',
  'Stylish UV protection sunglasses',
  149.99,
  'https://images.pexels.com/photos/701877/pexels-photo-701877.jpeg?auto=compress&cs=tinysrgb&w=400',
  70,
  4.4
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Designer Sunglasses');