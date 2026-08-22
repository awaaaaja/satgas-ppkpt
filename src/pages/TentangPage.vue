<script setup lang="ts">
import { RouterLink } from 'vue-router'
import SectionHeading from '@/components/ui/SectionHeading.vue'
import Badge from '@/components/ui/Badge.vue'
import AutoCarousel from '@/components/AutoCarousel.vue'
import {
  Crown,
  FileText,
  ShieldCheck,
  Megaphone,
  Search,
  HeartHandshake,
  ClipboardCheck,
  BookOpen,
} from 'lucide-vue-next'

const hukum = [
  { nama: 'Permendikbudristek Nomor 55 Tahun 2024', desc: 'Pencegahan dan Penanganan Kekerasan di Lingkungan Perguruan Tinggi.' },
  { nama: 'UU Nomor 12 Tahun 2022', desc: 'Tindak Pidana Kekerasan Seksual (TPKS).' },
  { nama: 'SK Rektor Nomor 191/UA/Kep/2024', desc: 'Penetapan Panitia Satuan Tugas PPKPT Universitas Adzkia (Desember 2024).' },
  { nama: 'Kode Etik Dosen dan Tenaga Kependidikan', desc: 'Norma perilaku pendidik dan tenaga kependidikan Universitas Adzkia.' },
  { nama: 'Kode Etik Mahasiswa', desc: 'Norma perilaku mahasiswa Universitas Adzkia.' },
]

// Ketua & Sekretaris — statis (tidak carousel), tetap animatif
const pimpinan = [
  { nama: 'Muzayyanah, Lc., M.A.', peran: 'Ketua', unsur: 'Dosen', icon: Crown, foto: null as string | null },
  { nama: 'Fadilla Windryani, S.Pd.', peran: 'Sekretaris', unsur: 'Tenaga Kependidikan', icon: FileText, foto: null as string | null },
]

// Anggota Dosen & Mahasiswa — bisa diolah di Admin Panel (Supabase satgas_dosen / satgas_mahasiswa)
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const dosenItems = ref<{ nama: string; jabatan: string; foto_url: string | null }[]>([
  { nama: 'Elva Zuleni, M.Pd.', jabatan: 'Anggota · Dosen', foto_url: null },
  { nama: 'Ringgi Rahmat Fitra, M.Pd.', jabatan: 'Anggota · Dosen', foto_url: null },
  { nama: 'Mutia Jawaz Muslim, M.H.', jabatan: 'Anggota · Dosen', foto_url: null },
  { nama: 'Nicky Nia Gustriani, S.Ip.', jabatan: 'Anggota · Tenaga Kependidikan', foto_url: null },
])
const mahasiswaItems = ref<{ nama: string; prodi: string; foto_url: string | null }[]>([
  { nama: 'Nala Fratika Sari', prodi: 'Mahasiswa PGSD', foto_url: null },
  { nama: 'Nurrahmi Juwita', prodi: 'Mahasiswa PGSD', foto_url: null },
  { nama: 'Eni Azzahra', prodi: 'Mahasiswa PGSD', foto_url: null },
  { nama: 'Haikal Fatwa Rachmansyah', prodi: 'Mahasiswa Informatika', foto_url: null },
  { nama: 'Muhammad Fajri', prodi: 'Mahasiswa Informatika', foto_url: null },
])

onMounted(async () => {
  // fetch dari Supabase — jika ada data, pakai foto_url dari DB (bisa foto islami open-source yang diupload admin)
  const { data: dDosen } = await supabase.from('satgas_dosen').select('nama,jabatan,foto_url').order('urutan')
  if (dDosen && dDosen.length) dosenItems.value = dDosen as typeof dosenItems.value
  const { data: dMhs } = await supabase.from('satgas_mahasiswa').select('nama,prodi,foto_url').order('urutan')
  if (dMhs && dMhs.length) mahasiswaItems.value = dMhs as typeof mahasiswaItems.value
})

const fungsi = [
  { icon: BookOpen, judul: 'Menyusun Pedoman', desc: 'Membantu pimpinan perguruan tinggi menyusun pedoman Pencegahan dan Penanganan Kekerasan.' },
  { icon: Megaphone, judul: 'Sosialisasi', desc: 'Kesetaraan gender, hak disabilitas, pendidikan seksualitas, dan pencegahan kekerasan bagi warga kampus.' },
  { icon: ShieldCheck, judul: 'Terima Laporan', desc: 'Menerima dan menindaklanjuti laporan dugaan kekerasan.' },
  { icon: Search, judul: 'Tindak Lanjut Temuan', desc: 'Menindaklanjuti dan menangani temuan dugaan kekerasan.' },
  { icon: HeartHandshake, judul: 'Rujukan Layanan', desc: 'Memfasilitasi rujukan layanan pendampingan, pelindungan, dan pemulihan bagi korban dan saksi.' },
  { icon: ClipboardCheck, judul: 'Pemantauan', desc: 'Memantau pelaksanaan rekomendasi tindak lanjut hasil pemeriksaan.' },
]

const initials = (n: string) =>
  n
    .split(' ')
    .slice(0, 2)
    .map((w) => w[0])
    .join('')
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="mx-auto max-w-4xl px-4 py-16 md:px-6">
      <Badge tone="blue" class="mb-4">Universitas Adzkia</Badge>
      <h1 class="font-display text-3xl font-bold text-ink md:text-4xl">Tentang Satgas PPKPT</h1>
      <p class="mt-4 text-sm leading-relaxed text-ink-soft md:text-base">
        Satgas Pencegahan dan Penanganan Kekerasan di Perguruan Tinggi (PPKPT) Universitas Adzkia
        dibentuk berdasarkan amanat Permendikbudristek Nomor 55 Tahun 2024 dan ditetapkan melalui
        <strong class="text-ink">SK Rektor Nomor 191/UA/Kep/2024</strong>. Satgas bertugas
        melaksanakan pencegahan dan penanganan kekerasan di lingkungan kampus, dengan tujuan
        menciptakan lingkungan kampus yang aman, inklusif, dan bebas dari kekerasan.
      </p>
      <p class="mt-3 text-sm leading-relaxed text-ink-soft md:text-base">
        Sekretariat Satgas berada di <strong class="text-ink">Lantai 2 Gedung Lama</strong> Universitas Adzkia.
      </p>
    </section>

    <section class="mx-auto max-w-4xl px-4 pb-16 md:px-6">
      <SectionHeading heading="Dasar Hukum" lead="Payung regulasi pembentukan dan kerja Satgas PPKPT." />
      <div class="glass-gradient rounded-2xl p-6">
        <ul class="grid gap-4">
          <li v-for="h in hukum" :key="h.nama" class="flex gap-3">
            <span class="mt-1 text-brand-blue">•</span>
            <div>
              <p class="text-sm font-semibold text-ink">{{ h.nama }}</p>
              <p class="text-sm text-ink-soft">{{ h.desc }}</p>
            </div>
          </li>
        </ul>
        <RouterLink to="/unduhan" class="mt-5 inline-block text-sm font-medium text-link hover:underline">
          Unduh dokumen resmi →
        </RouterLink>
      </div>
    </section>

    <section class="mx-auto max-w-5xl px-4 pb-16 md:px-6">
      <SectionHeading heading="Struktur Satgas" lead="Anggota Satgas PPKPT Universitas Adzkia (SK No. 191/UA/Kep/2024)." />

      <!-- Ketua & Sekretaris — card statis biasa, tetap animatif -->
      <div class="grid gap-5 md:grid-cols-2">
        <div
          v-for="(p, i) in pimpinan"
          :key="p.nama"
          class="glass-gradient group relative overflow-hidden rounded-2xl p-5 transition-all duration-300 hover:-translate-y-1"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 80 } }"
        >
          <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-brand-blue/10 transition-transform duration-300 group-hover:scale-125" />
          <div class="relative flex items-center gap-4">
            <!-- placeholder islami open-source: inisial jika foto null -->
            <img
              :src="p.foto || `https://placehold.co/400x400/e8f1f9/1a6bb5?text=${encodeURIComponent(initials(p.nama))}`"
              :alt="`Foto ${p.nama}`"
              class="h-14 w-14 shrink-0 rounded-full object-cover border border-border"
              loading="lazy"
            />
            <div class="min-w-0">
              <p class="truncate font-display font-semibold text-ink">{{ p.nama }}</p>
              <p class="flex items-center gap-1.5 text-sm text-ink-soft">
                <component :is="p.icon" :size="14" class="text-brand-blue" />
                {{ p.peran }} <span class="text-muted">·</span> {{ p.unsur }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Anggota Dosen & Tendik — carousel auto-slide 2 card -->
      <div class="mt-10">
        <h3 class="font-display text-base font-bold text-ink">Anggota Dosen & Tendik</h3>
        <div class="mt-4">
          <AutoCarousel :items="dosenItems.map(d => ({ nama: d.nama, jabatan: d.jabatan, foto_url: d.foto_url }))" :visible-count="2" />
        </div>
      </div>

      <!-- Anggota Mahasiswa — carousel terpisah -->
      <div class="mt-10">
        <h3 class="font-display text-base font-bold text-ink">Anggota Mahasiswa</h3>
        <div class="mt-4">
          <AutoCarousel :items="mahasiswaItems.map(m => ({ nama: m.nama, prodi: m.prodi, foto_url: m.foto_url }))" :visible-count="2" />
        </div>
      </div>
    </section>

    <section class="mx-auto max-w-4xl px-4 pb-20 md:px-6">
      <SectionHeading heading="Fungsi Satgas" lead="Ruang lingkup kerja Satgas dalam mencegah dan menangani kekerasan." />
      <div class="grid gap-4 sm:grid-cols-2">
        <div
          v-for="(f, i) in fungsi"
          :key="f.judul"
          class="glass-gradient group rounded-2xl p-5 transition-all duration-300 hover:-translate-y-1"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 80 } }"
        >
          <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-blue/10 text-brand-blue transition-colors duration-300 group-hover:bg-brand-blue group-hover:text-white">
            <component :is="f.icon" :size="22" />
          </div>
          <p class="mt-3 font-display font-semibold text-ink">{{ f.judul }}</p>
          <p class="mt-1 text-sm text-ink-soft">{{ f.desc }}</p>
        </div>
      </div>
    </section>
  </div>
</template>