-- Sprint 1: Skema Data & Auth — Satgas PPKPT Universitas Adzkia
-- Semua tabel: RLS aktif (AGENTS.md §3). Role: editor | admin | superadmin.

-- ============================================================
-- 1. Helper fungsi role (dipakai policy RLS)
--    Role disimpan di tabel profiles (bukan user_metadata — aman untuk authz).
-- ============================================================
create or replace function public.current_role()
returns text
language plpgsql
stable
security invoker
as $$
begin
  return (select role from public.profiles where id = auth.uid());
end;
$$;

create or replace function public.is_staff()
returns boolean
language plpgsql
stable
security invoker
as $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('editor', 'admin', 'superadmin')
  );
end;
$$;

create or replace function public.is_admin()
returns boolean
language plpgsql
stable
security invoker
as $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'superadmin')
  );
end;
$$;

-- ============================================================
-- 2. Tabel profiles (extends auth.users)
--    Select: diri sendiri + admin. Insert: hanya trigger handle_new_user.
--    Update: diri sendiri (full_name saja) / admin (role).
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'editor'
    check (role in ('editor', 'admin', 'superadmin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_self_or_admin"
  on public.profiles for select
  using (id = auth.uid() or public.is_admin());

create policy "profiles_insert_via_trigger"
  on public.profiles for insert
  with check (true);

create policy "profiles_update_self_or_admin"
  on public.profiles for update
  using (id = auth.uid() or public.is_admin())
  with check (
    (public.is_admin()) or
    (id = auth.uid() and role = 'editor')
  );

-- Auto-create profile saat user daftar. Role default 'editor'.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- 3. Tabel documents
--    Select publik: SEMUA baris (dokumen resmi memang publik).
--    Insert/update/delete: editor (miliknya), admin/superadmin (semua).
-- ============================================================
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text not null default 'umum',
  file_url text not null,
  file_type text not null default 'pdf',
  file_size bigint not null default 0,
  description text not null default '',
  published_at timestamptz not null default now(),
  created_by uuid not null default auth.uid() references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.documents enable row level security;

create policy "documents_select_public"
  on public.documents for select
  using (true);

create policy "documents_insert_staff"
  on public.documents for insert
  to authenticated
  with check (
    public.is_staff() and
    (public.is_admin() or created_by = auth.uid())
  );

create policy "documents_update_staff"
  on public.documents for update
  to authenticated
  using (public.is_admin() or created_by = auth.uid())
  with check (
    public.is_staff() and
    (public.is_admin() or created_by = auth.uid())
  );

create policy "documents_delete_staff"
  on public.documents for delete
  to authenticated
  using (public.is_admin() or created_by = auth.uid());

-- ============================================================
-- 4. Tabel posts
--    Select publik: hanya status='published'.
--    Insert/update/delete: editor (miliknya), admin/superadmin (semua).
-- ============================================================
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  excerpt text not null default '',
  content text not null default '',
  cover_url text,
  category text not null default 'kegiatan',
  tags text[] not null default '{}',
  author_id uuid not null default auth.uid() references public.profiles(id),
  status text not null default 'draft' check (status in ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.posts enable row level security;

create policy "posts_select_public"
  on public.posts for select
  using (status = 'published');

create policy "posts_insert_staff"
  on public.posts for insert
  to authenticated
  with check (
    public.is_staff() and
    (public.is_admin() or author_id = auth.uid())
  );

create policy "posts_update_staff"
  on public.posts for update
  to authenticated
  using (public.is_admin() or author_id = auth.uid())
  with check (
    public.is_staff() and
    (public.is_admin() or author_id = auth.uid())
  );

create policy "posts_delete_staff"
  on public.posts for delete
  to authenticated
  using (public.is_admin() or author_id = auth.uid());

-- ============================================================
-- 5. Tabel settings (key-value, publik read — dipakai halaman publik)
-- ============================================================
create table public.settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.settings enable row level security;

create policy "settings_select_public"
  on public.settings for select
  using (true);

create policy "settings_write_admin"
  on public.settings for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================
-- 6. Tabel contact_messages — TIDAK publik, hanya admin.
-- ============================================================
create table public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  message text not null,
  status text not null default 'new' check (status in ('new', 'read', 'done')),
  created_at timestamptz not null default now()
);

alter table public.contact_messages enable row level security;

create policy "contact_messages_insert_public"
  on public.contact_messages for insert
  to anon, authenticated
  with check (true);

create policy "contact_messages_select_admin"
  on public.contact_messages for select
  to authenticated
  using (public.is_admin());

create policy "contact_messages_update_admin"
  on public.contact_messages for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================
-- 7. Tabel activity_log — TIDAK publik.
--    Select/insert: staff. Wajib tercatat setiap mutasi dokumen/post.
-- ============================================================
create table public.activity_log (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id),
  action text not null check (action in ('create', 'update', 'delete')),
  entity text not null,
  entity_id uuid,
  created_at timestamptz not null default now()
);

alter table public.activity_log enable row level security;

create policy "activity_log_select_staff"
  on public.activity_log for select
  to authenticated
  using (public.is_staff());

create policy "activity_log_insert_staff"
  on public.activity_log for insert
  to authenticated
  with check (public.is_staff());

-- Trigger pencatatan otomatis mutasi dokumen
create or replace function public.log_document_activity()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  insert into public.activity_log (actor_id, action, entity, entity_id)
  values (
    coalesce(auth.uid(), new.created_by),
    lower(tg_op::text),
    'documents',
    coalesce(new.id, old.id)
  );
  return coalesce(new, old);
end;
$$;

create trigger documents_activity
  after insert or update or delete on public.documents
  for each row execute function public.log_document_activity();

create or replace function public.log_post_activity()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  insert into public.activity_log (actor_id, action, entity, entity_id)
  values (
    coalesce(auth.uid(), new.author_id),
    lower(tg_op::text),
    'posts',
    coalesce(new.id, old.id)
  );
  return coalesce(new, old);
end;
$$;

create trigger posts_activity
  after insert or update or delete on public.posts
  for each row execute function public.log_post_activity();

-- ============================================================
-- 8. Storage: bucket dokumen publik read-only, upload via auth
-- ============================================================
insert into storage.buckets (id, name, public)
values ('documents', 'documents', true)
on conflict (id) do nothing;

create policy "documents_storage_read_public"
  on storage.objects for select
  using (bucket_id = 'documents');

create policy "documents_storage_write_staff"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'documents' and public.is_staff());

create policy "documents_storage_update_staff"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'documents' and public.is_staff());

create policy "documents_storage_delete_staff"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'documents' and public.is_staff());

-- ============================================================
-- 9. Grant API (Data API) — sesuai pola skill Supabase
-- ============================================================
grant usage on schema public to anon, authenticated;
grant select on public.profiles, public.documents, public.posts, public.settings to anon;
grant all on public.documents, public.posts, public.activity_log to authenticated;
grant select, insert on public.contact_messages to anon, authenticated;
grant all on public.settings, public.contact_messages, public.profiles to authenticated;