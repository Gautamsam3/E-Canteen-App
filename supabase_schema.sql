-- Supabase Database Schema for FoodieHub E-Canteen App
-- Run this in your Supabase SQL Editor

-- 1. Create profiles table for user information
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- 2. Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category TEXT NOT NULL,
  rating DECIMAL(3,2) DEFAULT 0.0,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  delivery_address TEXT,
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  special_instructions TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS Policies

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Menu items policies (read-only for all authenticated users)
CREATE POLICY "Anyone can view menu items" ON menu_items
  FOR SELECT USING (auth.role() = 'authenticated');

-- Orders policies
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders" ON orders
  FOR UPDATE USING (auth.uid() = user_id);

-- Order items policies
CREATE POLICY "Users can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own order items" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

-- 7. Insert sample menu data
INSERT INTO menu_items (name, description, price, image_url, category, rating) VALUES
('Chicken Burger', 'Juicy grilled chicken with fresh vegetables', 299.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&h=400&fit=crop', 'Burgers', 4.5),
('Margherita Pizza', 'Classic pizza with tomato sauce and mozzarella', 449.00, 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&h=400&fit=crop', 'Pizza', 4.2),
('Caesar Salad', 'Fresh romaine lettuce with caesar dressing', 199.00, 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500&h=400&fit=crop', 'Salads', 4.0),
('Chocolate Cake', 'Rich chocolate cake with cream frosting', 149.00, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&h=400&fit=crop', 'Desserts', 4.8),
('Iced Coffee', 'Cold brew coffee with ice and milk', 99.00, 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500&h=400&fit=crop', 'Beverages', 4.3),
('Butter Chicken', 'Creamy tomato-based curry with tender chicken', 329.00, 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500&h=400&fit=crop', 'Indian', 4.7),
('Biryani', 'Aromatic basmati rice with spiced chicken', 279.00, 'https://images.unsplash.com/photo-1563379091339-03246963d272?w=500&h=400&fit=crop', 'Indian', 4.6),
('Masala Dosa', 'Crispy crepe with spiced potato filling', 89.00, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=500&h=400&fit=crop', 'Indian', 4.4),
('Fish & Chips', 'Beer-battered fish with crispy fries', 349.00, 'https://images.unsplash.com/photo-1544227099-6d9ac7f6b4b5?w=500&h=400&fit=crop', 'Western', 4.3),
('Pasta Carbonara', 'Creamy pasta with bacon and parmesan', 269.00, 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=500&h=400&fit=crop', 'Western', 4.5),
('Veg Sandwich', 'Fresh vegetables with mayo and cheese', 79.00, 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=500&h=400&fit=crop', 'Snacks', 4.1),
('French Fries', 'Crispy golden fries with seasoning', 69.00, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&h=400&fit=crop', 'Snacks', 4.2),
('Mango Lassi', 'Refreshing yogurt drink with mango', 59.00, 'https://images.unsplash.com/photo-1553787244-6e6d0a5fea43?w=500&h=400&fit=crop', 'Beverages', 4.4),
('Gulab Jamun', 'Sweet milk dumplings in sugar syrup', 89.00, 'https://images.unsplash.com/photo-1571167439851-4dd9b7027c65?w=500&h=400&fit=crop', 'Desserts', 4.6),
('Samosa', 'Crispy pastry with spiced potato filling', 39.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&h=400&fit=crop', 'Snacks', 4.3);

-- 8. Create functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 9. Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
