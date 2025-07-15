import 'package:postgres/postgres.dart';

Future<void> main() async {
  // Update these with your Supabase Postgres credentials
  final connection = PostgreSQLConnection(
    'db.uuwxksmmslgjjnvptwnj.supabase.co',
    5432,
    'postgres',
    username: 'postgres',
    password: 'Ek&j_iiy??78xqe',
    useSSL: true,
  );
  await connection.open();

  // Insert dummy menu items
  await connection.query('''
    INSERT INTO public.menu_items (name, description, price, image_url, category, available)
    VALUES
      ('Masala Dosa', 'Crispy rice crepe with spicy potato filling', 50.0, '', 'South Indian', true),
      ('Paneer Butter Masala', 'Cottage cheese in creamy tomato gravy', 90.0, '', 'North Indian', true),
      ('Veg Biryani', 'Aromatic rice with mixed vegetables', 80.0, '', 'Rice', true),
      ('Samosa', 'Crispy pastry with spicy potato filling', 15.0, '', 'Snacks', true)
    ON CONFLICT DO NOTHING;
  ''');

  // You can add more dummy inserts for profiles, orders, etc. as needed

  print('Dummy data inserted!');
  await connection.close();
}
