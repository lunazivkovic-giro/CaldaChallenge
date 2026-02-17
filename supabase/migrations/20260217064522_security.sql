drop policy "order_items_delete_own_orders" on "public"."order_items";

drop policy "order_items_insert_own_orders" on "public"."order_items";

drop policy "order_items_select_own_orders" on "public"."order_items";

drop policy "order_items_update_own_orders" on "public"."order_items";

drop policy "orders_delete_own" on "public"."orders";

drop policy "orders_insert_own" on "public"."orders";

drop policy "orders_select_own" on "public"."orders";

drop policy "orders_update_own" on "public"."orders";

drop policy "profiles_delete_own" on "public"."profiles";

drop policy "profiles_insert_own" on "public"."profiles";

drop policy "profiles_select_own" on "public"."profiles";

drop policy "profiles_update_own" on "public"."profiles";


  create policy "order_items_delete_own_orders"
  on "public"."order_items"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "order_items_insert_own_orders"
  on "public"."order_items"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "order_items_select_own_orders"
  on "public"."order_items"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "order_items_update_own_orders"
  on "public"."order_items"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid))))))
with check ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND (o.user_id = ( SELECT auth.uid() AS uid))))));



  create policy "orders_delete_own"
  on "public"."orders"
  as permissive
  for delete
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "orders_insert_own"
  on "public"."orders"
  as permissive
  for insert
  to authenticated
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "orders_select_own"
  on "public"."orders"
  as permissive
  for select
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "orders_update_own"
  on "public"."orders"
  as permissive
  for update
  to authenticated
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));



  create policy "profiles_delete_own"
  on "public"."profiles"
  as permissive
  for delete
  to authenticated
using ((id = ( SELECT auth.uid() AS uid)));



  create policy "profiles_insert_own"
  on "public"."profiles"
  as permissive
  for insert
  to authenticated
with check ((id = ( SELECT auth.uid() AS uid)));



  create policy "profiles_select_own"
  on "public"."profiles"
  as permissive
  for select
  to authenticated
using ((id = ( SELECT auth.uid() AS uid)));



  create policy "profiles_update_own"
  on "public"."profiles"
  as permissive
  for update
  to authenticated
using ((id = ( SELECT auth.uid() AS uid)))
with check ((id = ( SELECT auth.uid() AS uid)));



