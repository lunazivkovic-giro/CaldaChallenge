-- users
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at,is_sso_user) values
('00000000-0000-0000-0000-000000000000', 'bf855cd9-9e55-4be1-8593-bf9e83e2d3c3', 'authenticated', 'authenticated', 'lunazivkovic@gmail.com', crypt('password123', gen_salt('bf')), '2023-02-18 23:31:13.017218+00', NULL, '', '2023-02-18 23:31:12.757017+00', '', NULL, '', '', NULL, '2023-02-18 23:31:13.01781+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL, '2023-02-18 23:31:12.752281+00', '2023-02-18 23:31:13.019418+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, 'f'),
('00000000-0000-0000-0000-000000000000', '53769584-cec6-4960-a7f4-7264a9aeb999', 'authenticated', 'authenticated', 'lunazivkovic+1@gmail.com', crypt('password123', gen_salt('bf')), '2023-02-19 00:01:51.351735+00', NULL, '', '2023-02-19 00:01:51.147035+00', '', NULL, '', '', NULL, '2023-02-19 00:01:51.352369+00', '{"provider": "email", "providers": ["email"]}', '{}', NULL, '2023-02-19 00:01:51.142802+00', '2023-02-19 00:01:51.353896+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, 'f');

--profiles
insert into public.profiles (id, full_name, phone)
values
  ('bf855cd9-9e55-4be1-8593-bf9e83e2d3c3', 'Ana Novak', '+38640111222'),
  ('53769584-cec6-4960-a7f4-7264a9aeb999', 'Marko Kovač', '+38640111333')
on conflict (id) do update
set full_name = excluded.full_name,
    phone = excluded.phone;

--items
insert into public.items (id, name, price, stock)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'T-Shirt', 19.99, 50),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Hoodie', 49.99, 25),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Cap', 14.99, 80),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Sneakers', 89.99, 10),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Socks (3-pack)', 9.99, 100)
on conflict (id) do nothing;

--orders
insert into public.orders (
  id, user_id, recipient_name, shipping_address_line, shipping_city, shipping_postal_code, shipping_country, status
)
values
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    'bf855cd9-9e55-4be1-8593-bf9e83e2d3c3',
    'Tomaž Vidmar',
    'Dunajska cesta 1',
    'Ljubljana',
    '1000',
    'SI',
    'created'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
    'bf855cd9-9e55-4be1-8593-bf9e83e2d3c3',
    'Luka Kovač',
    'Trg republike 2',
    'Ljubljana',
    '1000',
    'SI',
    'paid'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
    '53769584-cec6-4960-a7f4-7264a9aeb999',
    'Maja Novak',
    'Slovenska cesta 10',
    'Ljubljana',
    '1000',
    'SI',
    'created'
  )
on conflict (id) do nothing;

--order_items
insert into public.order_items (order_id, item_id, quantity, unit_price)
values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 2, 19.99),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 1, 14.99),

  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 5, 49.99),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 3, 9.99),

  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 1, 89.99),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 1, 19.99)
on conflict (order_id, item_id) do nothing;

