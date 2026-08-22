-- Fix: fungsi log mengirim tg_op ('insert') yang tidak valid untuk
-- constraint activity_log_action_check ('create'|'update'|'delete').
-- Map: INSERT -> create, UPDATE -> update, DELETE -> delete.

create or replace function public.log_document_activity()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  insert into public.activity_log (actor_id, action, entity, entity_id)
  values (
    coalesce(auth.uid(), new.created_by, old.created_by),
    case lower(tg_op::text)
      when 'insert' then 'create'
      when 'update' then 'update'
      else 'delete'
    end,
    'documents',
    coalesce(new.id, old.id)
  );
  return coalesce(new, old);
end;
$$;

create or replace function public.log_post_activity()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  insert into public.activity_log (actor_id, action, entity, entity_id)
  values (
    coalesce(auth.uid(), new.author_id, old.author_id),
    case lower(tg_op::text)
      when 'insert' then 'create'
      when 'update' then 'update'
      else 'delete'
    end,
    'posts',
    coalesce(new.id, old.id)
  );
  return coalesce(new, old);
end;
$$;
