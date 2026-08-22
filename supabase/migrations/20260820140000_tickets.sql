-- Sprint 1b: Fitur Aduan & Ticket (SOP Penerimaan Laporan/Aduan — Diagram 2)
-- Pelapor TIDAK login; dapat nomor ticket + token akses untuk cek status.
-- Staff login untuk kelola: ubah status, tunjuk PIC, catat perkembangan.

-- ============================================================
-- 1. Tabel tickets
-- ============================================================
create sequence public.ticket_number_seq;

create table public.tickets (
  id uuid primary key default gen_random_uuid(),
  ticket_number text not null unique,
  category text not null default 'umum'
    check (category in ('preventif', 'intervensi', 'advokasi', 'umum')),
  title text not null,
  description text not null,
  reporter_name text not null default '',
  reporter_contact text not null default '',
  status text not null default 'diterima'
    check (status in ('diterima', 'ditinjau', 'diproses', 'selesai', 'ditolak')),
  priority text not null default 'normal'
    check (priority in ('normal', 'tinggi', 'darurat')),
  pic_id uuid references public.profiles(id),
  access_token uuid not null default gen_random_uuid(),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tickets enable row level security;

-- Pelapor anon/terdaftar bisa membuat ticket (tanpa login).
create policy "tickets_insert_public"
  on public.tickets for insert
  to anon, authenticated
  with check (status = 'diterima' and pic_id is null);

-- Ticket TIDAK bisa dibaca langsung oleh anon (hanya via RPC get_ticket_status).
create policy "tickets_select_staff"
  on public.tickets for select
  to authenticated
  using (public.is_staff());

-- Update: staff.
create policy "tickets_update_staff"
  on public.tickets for update
  to authenticated
  using (public.is_staff())
  with check (public.is_staff());

-- Nomor ticket: ADZ-YYYY-0001
create or replace function public.assign_ticket_number()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.ticket_number := 'ADZ-' || to_char(now(), 'YYYY') || '-' ||
    lpad(nextval('public.ticket_number_seq')::text, 4, '0');
  return new;
end;
$$;

create trigger tickets_number
  before insert on public.tickets
  for each row execute function public.assign_ticket_number();

-- Catat perubahan status ke ticket_updates secara otomatis
create or replace function public.log_ticket_status_change()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if old.status is distinct from new.status then
    insert into public.ticket_updates (ticket_id, actor_id, status_from, status_to)
    values (new.id, auth.uid(), old.status, new.status);
  end if;
  return new;
end;
$$;

create trigger tickets_status_change
  after update on public.tickets
  for each row execute function public.log_ticket_status_change();

-- ============================================================
-- 2. Tabel ticket_updates (riwayat perkembangan)
-- ============================================================
create table public.ticket_updates (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  actor_id uuid references public.profiles(id),
  note text not null default '',
  status_from text,
  status_to text,
  created_at timestamptz not null default now()
);

alter table public.ticket_updates enable row level security;

create policy "ticket_updates_select_staff"
  on public.ticket_updates for select
  to authenticated
  using (public.is_staff());

create policy "ticket_updates_insert_staff"
  on public.ticket_updates for insert
  to authenticated
  with check (public.is_staff());

-- ============================================================
-- 3. RPC cek status ticket — satu-satunya jalur anon baca ticket.
--    SECURITY DEFINER terbatas: hanya mengembalikan status/timeline,
--    input wajib (nomor + token), output null jika tidak cocok.
--    ponytail: satu-satunya security definer di public; jika butuh
--    audit ketat, ganti ke edge function + service role.
-- ============================================================
create or replace function public.get_ticket_status(
  p_ticket_number text,
  p_access_token uuid
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v jsonb;
begin
  select jsonb_build_object(
    'ticket_number', t.ticket_number,
    'status', t.status,
    'priority', t.priority,
    'category', t.category,
    'title', t.title,
    'created_at', t.created_at,
    'updated_at', t.updated_at,
    'pic', p.full_name,
    'updates', coalesce((
      select jsonb_agg(jsonb_build_object(
        'note', u.note,
        'status_to', u.status_to,
        'created_at', u.created_at
      ) order by u.created_at)
      from public.ticket_updates u
      where u.ticket_id = t.id
    ), '[]'::jsonb)
  ) into v
  from public.tickets t
  left join public.profiles p on p.id = t.pic_id
  where t.ticket_number = p_ticket_number
    and t.access_token = p_access_token;

  return v;
end;
$$;

revoke all on function public.get_ticket_status from public;
grant execute on function public.get_ticket_status to anon, authenticated;

-- ============================================================
-- 4. Grant API
-- ============================================================
grant select, insert, update on public.tickets, public.ticket_updates to authenticated;
grant insert on public.tickets to anon;
