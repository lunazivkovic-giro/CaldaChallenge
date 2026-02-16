
import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "npm:@supabase/supabase-js@2";
type OrderItem = { item_id: string; quantity: number; unit_price: number };

type Order = {
  recipient_name: string;
  shipping_address_line: string;
  shipping_city: string;
  shipping_postal_code: string;
  shipping_country: string;
  status?: string;
  items: OrderItem[];
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "POST only" });

  
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json(401, { error: "Missing Authorization header" });

  let body: Order;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "Invalid JSON" });
  }

  if (
    !body?.recipient_name ||
    !body?.shipping_address_line ||
    !body?.shipping_city ||
    !body?.shipping_postal_code ||
    !body?.shipping_country ||
    !Array.isArray(body?.items) ||
    body.items.length === 0
  ) {
    return json(400, { error: "Missing required fields" });
  }

  for (const it of body.items) {
    if (!it?.item_id || typeof it.quantity !== "number" || it.quantity <= 0 || typeof it.unit_price !== "number" || it.unit_price < 0) {
      return json(400, { error: "Invalid item in items[]" });
    }
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  

  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData?.user?.id) {
    return json(401, { error: "Invalid JWT" });
  }
  const userId = userData.user.id;

  const { data: orderRow, error: orderErr } = await supabase
    .from("orders")
    .insert({
      user_id: userId,
      recipient_name: body.recipient_name,
      shipping_address_line: body.shipping_address_line, 
      shipping_city: body.shipping_city,
      shipping_postal_code: body.shipping_postal_code,
      shipping_country: body.shipping_country,
      status: body.status ?? "created",
    })
    .select("id")
    .single();

  if (orderErr) {
    return json(400, { error: "Order insert failed", details: orderErr.message });
  }

  const orderId = orderRow.id as string;

  const orderItemsRows = body.items.map((it) => ({
    order_id: orderId,
    item_id: it.item_id,
    quantity: it.quantity,
    unit_price: it.unit_price
  }));

  
  const { error: itemsErr } = await supabase.from("order_items").insert(orderItemsRows);

  if (itemsErr) {
    await supabase.from("orders").delete().eq("id", orderId);
    return json(400, { error: "Order items insert failed", details: itemsErr.message });
  }

  const { data: otherItems, error: aggErr } = await supabase
  .from("order_items")
  .select("quantity, unit_price, order_id")
  .neq("order_id", orderId);

  if (aggErr) {
    return json(500, { error: "Aggregation failed", details: aggErr.message });
  }

  const sumOtherOrders = (otherItems ?? []).reduce((sum, r) => {
    return sum + Number(r.quantity) * Number(r.unit_price);
  }, 0);

  return json(200, {
    ok: true,
    order_id: orderId,
    sum_other_orders_total: Number(sumOtherOrders.toFixed(2)),
  });
});

