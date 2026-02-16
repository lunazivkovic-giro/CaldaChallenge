
  create table "public"."item_history" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "item_id" uuid not null,
    "operation" text not null,
    "changed_at" timestamp with time zone not null default now(),
    "changed_by" uuid,
    "old_row" jsonb,
    "new_row" jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


CREATE UNIQUE INDEX item_history_pkey ON public.item_history USING btree (id);

alter table "public"."item_history" add constraint "item_history_pkey" PRIMARY KEY using index "item_history_pkey";

alter table "public"."item_history" add constraint "item_history_changed_by_fkey" FOREIGN KEY (changed_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."item_history" validate constraint "item_history_changed_by_fkey";

alter table "public"."item_history" add constraint "item_history_item_id_fkey" FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE not valid;

alter table "public"."item_history" validate constraint "item_history_item_id_fkey";

alter table "public"."item_history" add constraint "item_history_operation_check" CHECK ((operation = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text]))) not valid;

alter table "public"."item_history" validate constraint "item_history_operation_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.log_item_changes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_user uuid;
begin
  v_user := auth.uid();

  if (tg_op = 'INSERT') then
    insert into public.item_history(item_id, operation, changed_by, old_row, new_row)
    values (new.id, 'INSERT', v_user, null, to_jsonb(new));
    return new;

  elsif (tg_op = 'UPDATE') then
    insert into public.item_history(item_id, operation, changed_by, old_row, new_row)
    values (new.id, 'UPDATE', v_user, to_jsonb(old), to_jsonb(new));
    return new;

  elsif (tg_op = 'DELETE') then
    insert into public.item_history(item_id, operation, changed_by, old_row, new_row)
    values (old.id, 'DELETE', v_user, to_jsonb(old), null);
    return old;
  end if;

  return null;
end;
$function$
;

grant delete on table "public"."item_history" to "anon";

grant insert on table "public"."item_history" to "anon";

grant references on table "public"."item_history" to "anon";

grant select on table "public"."item_history" to "anon";

grant trigger on table "public"."item_history" to "anon";

grant truncate on table "public"."item_history" to "anon";

grant update on table "public"."item_history" to "anon";

grant delete on table "public"."item_history" to "authenticated";

grant insert on table "public"."item_history" to "authenticated";

grant references on table "public"."item_history" to "authenticated";

grant select on table "public"."item_history" to "authenticated";

grant trigger on table "public"."item_history" to "authenticated";

grant truncate on table "public"."item_history" to "authenticated";

grant update on table "public"."item_history" to "authenticated";

grant delete on table "public"."item_history" to "service_role";

grant insert on table "public"."item_history" to "service_role";

grant references on table "public"."item_history" to "service_role";

grant select on table "public"."item_history" to "service_role";

grant trigger on table "public"."item_history" to "service_role";

grant truncate on table "public"."item_history" to "service_role";

grant update on table "public"."item_history" to "service_role";

CREATE TRIGGER trg_items_history AFTER INSERT OR DELETE OR UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_item_changes();


