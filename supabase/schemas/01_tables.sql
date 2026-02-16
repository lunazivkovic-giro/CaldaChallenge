create extension if not exists "uuid-ossp";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

-- ITEMS
create table if not exists public.items (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  price numeric(10,2) not null,
  stock int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_items_name on public.items(name);

create trigger trg_items_updated_at
before update on public.items
for each row
execute function public.set_updated_at();

-- ORDERS
create table if not exists public.orders (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete restrict, -- can't delete user if they still have orders
  recipient_name text not null,
  shipping_address_line text not null,
  shipping_city text not null,
  shipping_postal_code text not null,
  shipping_country text not null,
  status text not null default 'created',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.orders
  add constraint orders_status_check
  check (status in ('created','paid','shipped','delivered','cancelled'));
  
create index if not exists idx_orders_user_id on public.orders(user_id);

create trigger trg_orders_updated_at
before update on public.orders
for each row
execute function public.set_updated_at();

-- ORDER_ITEMS
create table if not exists public.order_items (
  order_id uuid not null references public.orders(id) on delete cascade, -- if order is deleted, delete also order_item
  item_id uuid not null references public.items(id) on delete restrict, -- can't delete item if it's referenced in order_item
  quantity int not null default 1 check (quantity > 0),
  unit_price numeric(10,2) not null check (unit_price >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (order_id, item_id)
);


create index if not exists idx_order_items_order_id on public.order_items(order_id);
create index if not exists idx_order_items_item_id on public.order_items(item_id);

create trigger trg_order_items_updated_at
before update on public.order_items
for each row
execute function public.set_updated_at();


create table if not exists public.item_history (
  id uuid primary key default uuid_generate_v4(),
  item_id uuid not null references public.items(id) on delete cascade,
  operation text not null check (operation in ('INSERT','UPDATE','DELETE')),
  changed_at timestamptz not null default now(),
  changed_by uuid references public.profiles(id) on delete set null,
  old_row jsonb,
  new_row jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_item_history_updated_at
before update on public.item_history
for each row
execute function public.set_updated_at();


create table if not exists public.order_totals_archive (
  id uuid primary key default uuid_generate_v4(),
  run_at timestamptz not null default now(),
  deleted_orders_count int not null,
  totals_sum numeric(12,2) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_order_totals_archive_updated_at
before update on public.order_totals_archive
for each row
execute function public.set_updated_at();