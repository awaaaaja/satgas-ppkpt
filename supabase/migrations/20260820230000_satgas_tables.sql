-- Tabel Satgas — bisa diolah di Admin Panel, foto islami open-source
create table if not exists public.satgas_dosen (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  jabatan text not null,
  foto_url text,
  urutan int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.satgas_mahasiswa (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  prodi text not null,
  foto_url text,
  urutan int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- trigger updated_at
create or replace function public.set_satgas_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_satgas_dosen_updated on public.satgas_dosen;
create trigger trg_satgas_dosen_updated before update on public.satgas_dosen
for each row execute function public.set_satgas_updated_at();

drop trigger if exists trg_satgas_mahasiswa_updated on public.satgas_mahasiswa;
create trigger trg_satgas_mahasiswa_updated before update on public.satgas_mahasiswa
for each row execute function public.set_satgas_updated_at();

-- RLS
alter table public.satgas_dosen enable row level security;
alter table public.satgas_mahasiswa enable row level security;

-- public bisa baca (untuk halaman Tentang)
drop policy if exists satgas_dosen_select_public on public.satgas_dosen;
create policy satgas_dosen_select_public on public.satgas_dosen for select using (true);

drop policy if exists satgas_mahasiswa_select_public on public.satgas_mahasiswa;
create policy satgas_mahasiswa_select_public on public.satgas_mahasiswa for select using (true);

-- hanya staff bisa tulis (Admin Panel)
drop policy if exists satgas_dosen_write_staff on public.satgas_dosen;
create policy satgas_dosen_write_staff on public.satgas_dosen for all to authenticated using (is_staff()) with check (is_staff());

drop policy if exists satgas_mahasiswa_write_staff on public.satgas_mahasiswa;
create policy satgas_mahasiswa_write_staff on public.satgas_mahasiswa for all to authenticated using (is_staff()) with check (is_staff());

-- seed awal dari SK 191/UA/Kep/2024 — foto_url null akan jadi placeholder islami (initials) open-source
insert into public.satgas_dosen (nama, jabatan, urutan) values
  ('Elva Zuleni, M.Pd.', 'Anggota · Dosen', 1),
  ('Ringgi Rahmat Fitra, M.Pd.', 'Anggota · Dosen', 2),
  ('Mutia Jawaz Muslim, M.H.', 'Anggota · Dosen', 3),
  ('Nicky Nia Gustriani, S.Ip.', 'Anggota · Tenaga Kependidikan', 4)
on conflict do nothing;

insert into public.satgas_mahasiswa (nama, prodi, urutan) values
  ('Nala Fratika Sari', 'Mahasiswa PGSD', 1),
  ('Nurrahmi Juwita', 'Mahasiswa PGSD', 2),
  ('Eni Azzahra', 'Mahasiswa PGSD', 3),
  ('Haikal Fatwa Rachmansyah', 'Mahasiswa Informatika', 4),
  ('Muhammad Fajri', 'Mahasiswa Informatika', 5)
on conflict do nothing;
