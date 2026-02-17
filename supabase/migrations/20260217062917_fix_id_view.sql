set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.archive_and_delete_old_orders()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  v_count int := 0;
  v_sum numeric(12,2) := 0;
begin
  with old_orders as (
    select
      v.id,
      v.order_total
    from public.v_order_aggregates v
    where v.created_at < now() - interval '7 days'
  )
  select
    count(*),
    coalesce(sum(order_total), 0)::numeric(12,2)
  into v_count, v_sum
  from old_orders;

  insert into public.order_totals_archive (deleted_orders_count, totals_sum)
  values (v_count, v_sum);

  delete from public.orders o
  where o.created_at < now() - interval '7 days';
end;
$function$
;


