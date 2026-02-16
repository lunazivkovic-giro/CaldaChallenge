alter table public.profiles enable row level security;
alter table public.items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_delete_own" on public.profiles;

drop policy if exists "items_crud_authenticated" on public.items;

drop policy if exists "orders_select_own" on public.orders;
drop policy if exists "orders_insert_own" on public.orders;
drop policy if exists "orders_update_own" on public.orders;
drop policy if exists "orders_delete_own" on public.orders;

drop policy if exists "order_items_select_own_orders" on public.order_items;
drop policy if exists "order_items_insert_own_orders" on public.order_items;
drop policy if exists "order_items_update_own_orders" on public.order_items;
drop policy if exists "order_items_delete_own_orders" on public.order_items;

-- users: user can CRUD only their own profile
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (id = auth.uid());

create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check (id = auth.uid());

create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "profiles_delete_own"
on public.profiles
for delete
to authenticated
using (id = auth.uid());

-- items: authenticated users can CRUD
create policy "items_crud_authenticated"
on public.items
for all
to authenticated
using (true)
with check (true);

-- orders: only owner can CRUD
create policy "orders_select_own"
on public.orders
for select
to authenticated
using (user_id = auth.uid());

create policy "orders_insert_own"
on public.orders
for insert
to authenticated
with check (user_id = auth.uid());

create policy "orders_update_own"
on public.orders
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "orders_delete_own"
on public.orders
for delete
to authenticated
using (user_id = auth.uid());

-- order_items: only for orders owned by the user
create policy "order_items_select_own_orders"
on public.order_items
for select
to authenticated
using (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.user_id = auth.uid()
  )
);

create policy "order_items_insert_own_orders"
on public.order_items
for insert
to authenticated
with check (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.user_id = auth.uid()
  )
);

create policy "order_items_update_own_orders"
on public.order_items
for update
to authenticated
using (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.user_id = auth.uid()
  )
);

create policy "order_items_delete_own_orders"
on public.order_items
for delete
to authenticated
using (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.user_id = auth.uid()
  )
);
