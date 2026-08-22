-- Fix: helper role memicu infinite recursion saat policy profiles dipanggil
-- (is_admin() -> select profiles -> policy profiles -> is_admin()...).
-- Helper jadi SECURITY DEFINER (pola standar Supabase untuk lookup role):
-- search_path terkunci, hanya baca role untuk auth.uid().

create or replace function public.current_role()
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  return (select role from public.profiles where id = auth.uid());
end;
$$;

create or replace function public.is_staff()
returns boolean
language plpgsql
stable
security definer
set search_path = public
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
security definer
set search_path = public
as $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'superadmin')
  );
end;
$$;
