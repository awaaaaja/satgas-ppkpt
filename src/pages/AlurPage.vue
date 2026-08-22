<script setup lang="ts">
import Button from '@/components/ui/Button.vue'
import { Inbox, FileSearch, UserCheck, Scale, ShieldCheck, Lock, FileWarning, ScrollText, UserMinus, GraduationCap } from 'lucide-vue-next'

const steps = [
  {
    icon: Inbox,
    title: 'Pelaporan',
    waktu: 'Kapan saja',
    desc: 'Pelapor (korban, saksi, warga kampus, atau pihak lain) menyampaikan laporan dugaan kekerasan melalui kanal resmi: form aduan daring, surat tertulis, telepon, pesan singkat, atau surel.',
  },
  {
    icon: FileSearch,
    title: 'Tindak Lanjut Pelaporan',
    waktu: 'Segera',
    desc: 'Satgas menelaah materi laporan: identifikasi korban/saksi/terlapor, bentuk kekerasan, kronologi, bukti, dan kebutuhan pendampingan. Satgas wajib menindaklanjuti setiap laporan yang diterima.',
  },
  {
    icon: UserCheck,
    title: 'Pemeriksaan',
    waktu: 'Maks. 30 hari kerja (+30)',
    desc: 'Surat permintaan keterangan kepada para pihak (pelapor, korban, saksi, terlapor). Pemeriksaan tertutup, dimulai paling lambat 3 hari kerja setelah tindak lanjut selesai.',
  },
  {
    icon: Scale,
    title: 'Kesimpulan & Rekomendasi',
    waktu: 'Maks. 7 hari kerja',
    desc: 'Hasil pemeriksaan dituangkan dalam Laporan Hasil Pemeriksaan (LHP), disusun paling lambat 3 hari kerja setelah pemeriksaan selesai, dengan pengecekan terhadap Permendikbudristek Nomor 55 Tahun 2024.',
  },
  {
    icon: ShieldCheck,
    title: 'Tindak Lanjut Hasil',
    waktu: 'Berkesinambungan',
    desc: 'Jika terbukti terjadi kekerasan: sanksi administratif dan/atau pemulihan korban. Jika tidak terbukti, perkara ditutup. Satgas memantau rekomendasi dan mencegah keberulangan.',
  },
]
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-3xl px-4 py-16 md:px-6">
      <h1 class="font-display text-3xl font-bold text-ink md:text-4xl">Alur Pelaporan</h1>
      <p class="mt-4 text-sm leading-relaxed text-ink-soft md:text-base">
        Mekanisme penanganan dugaan kekerasan di Universitas Adzkia mengikuti alur resmi
        Satgas PPKPT. Kerahasiaan identitas pihak yang terkait langsung dengan laporan
        dijamin dan dijunjung oleh seluruh anggota Satgas.
      </p>
    </section>

    <section class="mx-auto max-w-3xl px-4 pb-16 md:px-6">
      <ol class="relative">
        <div class="absolute bottom-4 left-7 top-4 w-0.5 bg-gradient-to-b from-brand-blue via-brand-blue-soft to-transparent" aria-hidden="true" />

        <li
          v-for="(s, i) in steps"
          :key="s.title"
          class="relative flex gap-5 pb-8 last:pb-0"
          v-motion
          :initial="{ opacity: 0, x: -16 }"
          :enter="{ opacity: 1, x: 0, transition: { duration: 450, delay: i * 150 } }"
        >
          <div class="relative z-10 flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-brand-blue to-brand-blue-soft text-white shadow-lg shadow-brand-blue/30">
            <component :is="s.icon" :size="24" />
            <span class="absolute -right-1.5 -top-1.5 flex h-6 w-6 items-center justify-center rounded-full bg-ink text-xs font-bold text-white">
              {{ i + 1 }}
            </span>
          </div>
          <div class="glass-gradient flex-1 rounded-2xl p-5">
            <div class="flex flex-wrap items-center gap-2">
              <p class="font-display font-semibold text-ink">{{ s.title }}</p>
              <span class="rounded-full bg-brand-blue/10 px-2.5 py-0.5 text-xs font-medium text-brand-blue">{{ s.waktu }}</span>
            </div>
            <p class="mt-1.5 text-sm leading-relaxed text-ink-soft">{{ s.desc }}</p>
          </div>
        </li>
      </ol>

      <!-- Pelaporan tertutup -->
      <div class="glass-gradient mt-8 rounded-2xl p-5" v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 450, delay: 500 } }">
        <div class="flex items-start gap-3">
          <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-blue/10 text-brand-blue">
            <Lock :size="20" />
          </div>
          <div>
            <p class="font-display text-sm font-bold text-ink">Pelaporan Tertutup</p>
            <p class="mt-1 text-sm leading-relaxed text-ink-soft">
              Dilakukan secara tertutup oleh Satgas PPKPT, berkoordinasi dengan unit atau lembaga lain jika dibutuhkan. <span class="text-xs text-muted">(Bab V Pasal 48, 53, 57, 66, 71)</span>
            </p>
          </div>
        </div>
        <img src="/brand/alur-sanksi.png" alt="Alur pelaporan dan sanksi Satgas PPKPT" class="mt-4 w-full rounded-xl border border-border object-contain" loading="lazy" />
      </div>

      <!-- Jenis Sanksi -->
      <div class="mt-8" v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 450, delay: 550 } }">
        <h2 class="font-display text-lg font-bold text-ink">Jenis Sanksi</h2>
        <p class="mt-1 text-sm text-ink-soft">Penentuan sanksi oleh Rektor berdasarkan rekomendasi Satgas PPKPT dan melihat dampak ke korban. <span class="text-xs text-muted">(Bab V Pasal 74-76)</span></p>

        <div class="mt-4 grid gap-4">
          <div class="glass-gradient rounded-2xl p-5">
            <div class="flex items-center gap-2">
              <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-brand-red/10 text-brand-red"><UserMinus :size="18" /></div>
              <p class="font-display text-sm font-bold text-ink">Pemberhentian Tetap</p>
            </div>
            <p class="mt-2 text-sm text-ink-soft">Pemberhentian tetap sebagai dosen dan tenaga kependidikan atau mahasiswa.</p>
          </div>

          <div class="grid gap-4 sm:grid-cols-2">
            <div class="glass-gradient rounded-2xl p-5">
              <div class="flex items-center gap-2">
                <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-brand-blue/10 text-brand-blue"><FileWarning :size="18" /></div>
                <p class="font-display text-sm font-bold text-ink">Teguran Tertulis</p>
              </div>
              <p class="mt-2 text-sm text-ink-soft">Peneguran dilakukan secara tertulis.</p>
            </div>
            <div class="glass-gradient rounded-2xl p-5">
              <div class="flex items-center gap-2">
                <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-brand-blue/10 text-brand-blue"><ScrollText :size="18" /></div>
                <p class="font-display text-sm font-bold text-ink">Surat Pernyataan</p>
              </div>
              <p class="mt-2 text-sm text-ink-soft">Pernyataan permohonan maaf secara tertulis dari Pelaku kepada Korban.</p>
            </div>
          </div>

          <div class="grid gap-4 sm:grid-cols-2">
            <div class="glass-gradient rounded-2xl p-5">
              <p class="font-display text-sm font-bold text-ink">Dosen & Tenaga Kependidikan</p>
              <p class="mt-2 text-sm leading-relaxed text-ink-soft">Penurunan jenjang jabatan akademik dosen atau penurunan jenjang jabatan fungsional tenaga kependidikan selama 12 bulan.</p>
            </div>
            <div class="glass-gradient rounded-2xl p-5">
              <div class="flex items-center gap-2">
                <GraduationCap :size="18" class="text-brand-blue" />
                <p class="font-display text-sm font-bold text-ink">Mahasiswa</p>
              </div>
              <p class="mt-2 text-sm leading-relaxed text-ink-soft">Penundaan mengikuti perkuliahan, pencabutan beasiswa, atau pengurangan hak lain sesuai ketentuan peraturan perundang-undangan.</p>
            </div>
          </div>
        </div>
      </div>

      <div class="glass-gradient mt-8 rounded-2xl p-5" v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 450, delay: 600 } }">
        <p class="text-sm font-semibold text-ink">Mulai laporan</p>
        <p class="mt-2 text-sm text-ink-soft">
          Laporan dapat disampaikan tanpa perlu masuk akun. Anda akan mendapat nomor tiket
          untuk memantau perkembangan laporan.
        </p>
        <Button to="/aduan" class="mt-4">Buat Aduan</Button>
      </div>
    </section>
  </div>
</template>