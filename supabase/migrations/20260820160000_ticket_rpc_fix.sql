-- Perbaikan create_ticket: hindari RETURNING (anon tak punya SELECT policy).
-- Generate ticket_number + access_token di fungsi sebelum insert.

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
  v_num text;
  v_tok uuid;
begin
  v_num := 'ADZ-' || to_char(now(), 'YYYY') || '-' ||
    lpad(nextval('public.ticket_number_seq')::text, 4, '0');
  v_tok := gen_random_uuid();

  insert into public.tickets (
    ticket_number, access_token, title, description, category,
    reporter_name, reporter_contact
  ) values (
    v_num, v_tok, p_title, p_description, p_category,
    p_reporter_name, p_reporter_contact
  );

  return query select v_num, v_tok;
end;
$$;

revoke all on function public.create_ticket from public;
grant execute on function public.create_ticket to anon, authenticated;
