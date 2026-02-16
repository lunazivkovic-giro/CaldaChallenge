select operation, changed_at, changed_by
from public.item_history
order by changed_at desc
limit 5;
