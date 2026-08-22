-- Bucket gambar (foto publik berita/cover) + RLS policy storage.objects
-- Migrasi dibuat setelah bucket dibuat manual via SQL service role.

-- (Bucket dibuat terpisah: storage.buckets id='gambar', public=true,
--  file_size_limit 10 MB, mime image/webp|jpeg|png.)

create policy "gambar_storage_write_staff"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gambar' and is_staff());

create policy "gambar_storage_update_staff"
  on storage.objects for update to authenticated
  using (bucket_id = 'gambar' and is_staff());

create policy "gambar_storage_delete_staff"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gambar' and is_staff());