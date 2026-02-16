create or replace function public.log_item_changes()
returns trigger
language plpgsql
as $$
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
$$;

drop trigger if exists trg_items_history on public.items;
create trigger trg_items_history
after insert or update or delete on public.items
for each row
execute function public.log_item_changes();
