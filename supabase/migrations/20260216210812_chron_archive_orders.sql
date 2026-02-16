create extension if not exists "pg_cron" with schema "pg_catalog";


  create table "public"."order_totals_archive" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "run_at" timestamp with time zone not null default now(),
    "deleted_orders_count" integer not null,
    "totals_sum" numeric(12,2) not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


CREATE UNIQUE INDEX order_totals_archive_pkey ON public.order_totals_archive USING btree (id);

alter table "public"."order_totals_archive" add constraint "order_totals_archive_pkey" PRIMARY KEY using index "order_totals_archive_pkey";

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
      v.order_id,
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

create or replace view "public"."v_order_aggregates" as  SELECT o.id,
    o.user_id,
    o.recipient_name,
    o.shipping_address_line,
    o.shipping_city,
    o.shipping_postal_code,
    o.shipping_country,
    o.status,
    o.created_at,
    o.updated_at,
    COALESCE(jsonb_agg(jsonb_build_object('item_id', oi.item_id, 'name', i.name, 'quantity', oi.quantity, 'unit_price', oi.unit_price) ORDER BY i.name) FILTER (WHERE (oi.item_id IS NOT NULL)), '[]'::jsonb) AS order_items,
    (COALESCE(sum(((oi.quantity)::numeric * oi.unit_price)), (0)::numeric))::numeric(12,2) AS order_total
   FROM ((public.orders o
     LEFT JOIN public.order_items oi ON ((oi.order_id = o.id)))
     LEFT JOIN public.items i ON ((i.id = oi.item_id)))
  GROUP BY o.id, o.user_id, o.recipient_name, o.shipping_address_line, o.shipping_city, o.shipping_postal_code, o.shipping_country, o.status, o.created_at, o.updated_at;


grant delete on table "public"."order_totals_archive" to "anon";

grant insert on table "public"."order_totals_archive" to "anon";

grant references on table "public"."order_totals_archive" to "anon";

grant select on table "public"."order_totals_archive" to "anon";

grant trigger on table "public"."order_totals_archive" to "anon";

grant truncate on table "public"."order_totals_archive" to "anon";

grant update on table "public"."order_totals_archive" to "anon";

grant delete on table "public"."order_totals_archive" to "authenticated";

grant insert on table "public"."order_totals_archive" to "authenticated";

grant references on table "public"."order_totals_archive" to "authenticated";

grant select on table "public"."order_totals_archive" to "authenticated";

grant trigger on table "public"."order_totals_archive" to "authenticated";

grant truncate on table "public"."order_totals_archive" to "authenticated";

grant update on table "public"."order_totals_archive" to "authenticated";

grant delete on table "public"."order_totals_archive" to "service_role";

grant insert on table "public"."order_totals_archive" to "service_role";

grant references on table "public"."order_totals_archive" to "service_role";

grant select on table "public"."order_totals_archive" to "service_role";

grant trigger on table "public"."order_totals_archive" to "service_role";

grant truncate on table "public"."order_totals_archive" to "service_role";

grant update on table "public"."order_totals_archive" to "service_role";

CREATE TRIGGER trg_item_history_updated_at BEFORE UPDATE ON public.item_history FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_order_totals_archive_updated_at BEFORE UPDATE ON public.order_totals_archive FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


