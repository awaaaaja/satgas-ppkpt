-- Trigger updated_at untuk tickets
create or replace function public.set_ticket_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger tickets_updated_at
  before update on public.tickets
  for each row execute function public.set_ticket_updated_at();
