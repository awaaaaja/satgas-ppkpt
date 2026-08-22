-- Perbaikan: hilangkan trigger assign_ticket_number (double nextval
-- menyebabkan nomor yang dikembalikan create_ticket != yang tersimpan).
-- Kini hanya create_ticket yang assign nomor eksplisit;
-- anon/authenticated langsung insert ke tabel tanpa nomor -> ditolak NOT NULL.

drop trigger if exists tickets_number on public.tickets;

-- Function tetap dipakai create_ticket (lihat migrasi sebelumnya).
