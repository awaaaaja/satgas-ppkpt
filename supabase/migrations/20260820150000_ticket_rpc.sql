-- Sprint 1b: RPC buat ticket — satu-satunya cara anon membuat & mendapat token.
-- Security INVOKER (bukan definer): INSERT kena RLS insert anon (lolos),
-- lalu RETURNING hasil insert TIDAK kena RLS select, jadi anon dapat token.

create or replace function public.create_ticket(
  p_title text,
  p_description text,
  p_category text default 'umum',
  p_reporter_name text default '',
  p_reporter_contact text default ''
) returns table (
  ticket_number text,
  access_token uuid
)
language plpgsql
security invoker
set search_path = public
as $$
declare
  v public.tickets%rowtype;
begin
  insert into public.tickets (title, description, category, reporter_name, reporter_contact)
  values (p_title, p_description, p_category, p_reporter_name, p_reporter_contact)
  returning * into v;

  return query select v.ticket_number, v.access_token;
end;
$$;

revoke all on function public.create_ticket from public;
grant execute on function public.create_ticket to anon, authenticated;
