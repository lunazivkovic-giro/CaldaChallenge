create or replace view public.v_order_aggregates
with (security_invoker=on) as
select
  o.id,
  o.user_id,
  o.recipient_name,
  o.shipping_address_line,
  o.shipping_city,
  o.shipping_postal_code,
  o.shipping_country,
  o.status,
  o.created_at,
  o.updated_at,

  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'item_id', oi.item_id,
        'name', i.name,
        'quantity', oi.quantity,
        'unit_price', oi.unit_price
      )
      order by i.name
    ) filter (where oi.item_id is not null),
    '[]'::jsonb
  ) as order_items,
 coalesce(sum(oi.quantity * oi.unit_price), 0)::numeric(12,2) as order_total
from public.orders o
left join public.order_items oi on oi.order_id = o.id
left join public.items i on i.id = oi.item_id
group by
  o.id, o.user_id, o.recipient_name, o.shipping_address_line, o.shipping_city,
  o.shipping_postal_code, o.shipping_country, o.status, o.created_at, o.updated_at;

grant select on public.v_order_aggregates to authenticated;
