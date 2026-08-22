-- posts: staff perlu SELECT draft untuk RETURNING setelah INSERT
-- sebelumnya hanya ada posts_select_public (status='published') sehingga INSERT ... RETURNING draft gagal RLS 42501
create policy posts_select_staff
  on public.posts for select to authenticated
  using (is_staff() or status = 'published');