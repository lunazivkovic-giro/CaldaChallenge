alter table "public"."item_history" enable row level security;

alter table "public"."order_totals_archive" enable row level security;


  create policy "item_history_select_auth"
  on "public"."item_history"
  as permissive
  for select
  to authenticated
using (true);



  create policy "order_totals_archive_select_auth"
  on "public"."order_totals_archive"
  as permissive
  for select
  to authenticated
using (true);



