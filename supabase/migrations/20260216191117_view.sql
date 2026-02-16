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
    COALESCE(jsonb_agg(jsonb_build_object('item_id', oi.item_id, 'name', i.name, 'quantity', oi.quantity, 'unit_price', oi.unit_price) ORDER BY i.name) FILTER (WHERE (oi.item_id IS NOT NULL)), '[]'::jsonb) AS order_items
   FROM ((public.orders o
     LEFT JOIN public.order_items oi ON ((oi.order_id = o.id)))
     LEFT JOIN public.items i ON ((i.id = oi.item_id)))
  GROUP BY o.id, o.user_id, o.recipient_name, o.shipping_address_line, o.shipping_city, o.shipping_postal_code, o.shipping_country, o.status, o.created_at, o.updated_at;



