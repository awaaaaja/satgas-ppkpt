<script setup lang="ts">
import { ref, onMounted } from 'vue'
import AutoCarousel from '@/components/AutoCarousel.vue'
import { supabase } from '@/lib/supabase'
import { Crown, FileText } from 'lucide-vue-next'

// Ketua & Sekretaris — card statis biasa, tetap animatif (pakai motion, bukan carousel)
const ketua = { nama: 'Muzayyanah, Lc., M.A.', jabatan: 'Ketua · Dosen', foto_url: null as string | null }
const sekretaris = { nama: 'Fadilla Windryani, S.Pd.', jabatan: 'Sekretaris · Tenaga Kependidikan', foto_url: null as string | null }

// Data dosen & mahasiswa — dari Supabase (contoh query)
const dosen = ref<{ nama: string; jabatan: string; foto_url: string | null }[]>([])
const mahasiswa = ref<{ nama: string; prodi: string; foto_url: string | null }[]>([])
const loading = ref(true)

// Contoh fetch Supabase — tabel satgas_dosen & satgas_mahasiswa
// kolom: nama, jabatan/prodi, foto_url
// Jika tabel belum ada, fallback ke data statis placeholder islami
async function fetchDosen() {
  const { data, error } = await supabase.from('satgas_dosen').select('nama,jabatan,foto_url').order('nama')
  if (!error && data && data.length) {
    dosen.value = data as typeof dosen.value
  } else {
    // fallback statis — foto_url null akan jadi placeholder initials (islami, open-source placehold.co)
    dosen.value = [
      { nama: 'Elva Zuleni, M.Pd.', jabatan: 'Anggota · Dosen', foto_url: null },
      { nama: 'Ringgi Rahmat Fitra, M.Pd.', jabatan: 'Anggota · Dosen', foto_url: null },
      { nama: 'Mutia Jawaz Muslim, M.H.', jabatan: 'Anggota · Dosen', foto_url: null },
    ]
  }
}

async function fetchMahasiswa() {
  const { data, error } = await supabase.from('satgas_mahasiswa').select('nama,prodi,foto_url').order('nama')
  if (!error && data && data.length) {
    // map prodi -> prodi field
    mahasiswa.value = (data as { nama: string; prodi: string; foto_url: string | null }[])
  } else {
    mahasiswa.value = [
      { nama: 'Nala Fratika Sari', prodi: 'Mahasiswa PGSD', foto_url: null },
      { nama: 'Nurrahmi Juwita', prodi: 'Mahasiswa PGSD', foto_url: null },
      { nama: 'Eni Azzahra', prodi: 'Mahasiswa PGSD', foto_url: null },
      { nama: 'Haikal Fatwa Rachmansyah', prodi: 'Mahasiswa Informatika', foto_url: null },
      { nama: 'Muhammad Fajri', prodi: 'Mahasiswa Informatika', foto_url: null },
    ]
  }
}

onMounted(async () => {
  await Promise.all([fetchDosen(), fetchMahasiswa()])
  loading.value = false
})

// helper inisial untuk card statis
function initials(nama: string) {
  return nama.split(' ').filter(Boolean).slice(0, 2).map((w) => w[0]?.toUpperCase() ?? '').join('')
}
function placeholder(nama: string) {
  return `https://placehold.co/400x400/e8f1f9/1a6bb5?text=${encodeURIComponent(initials(nama))}`
}
</script>

<template>
  <div class="brand-gradient-bg">
    <!-- Ketua & Sekretaris — statis, tidak carousel, tetap animatif -->
    <section class="mx-auto max-w-5xl px-4 py-10 md:px-6">
      <h2 class="font-display text-xl font-bold text-ink">Pimpinan Satgas</h2>

      <div class="mt-6 grid gap-5 md:grid-cols-2">
        <!-- Ketua -->
        <div
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400 } }"
          class="glass-gradient rounded-2xl p-5 flex items-center gap-4"
        >
          <img :src="ketua.foto_url || placeholder(ketua.nama)" :alt="`Foto ${ketua.nama}`" class="h-20 w-20 shrink-0 rounded-full object-cover border border-border" loading="lazy" />
          <div>
            <p class="flex items-center gap-1.5 font-display font-semibold text-ink"><Crown :size="16" class="text-brand-blue" /> {{ ketua.nama }}</p>
            <p class="text-sm text-ink-soft">{{ ketua.jabatan }}</p>
          </div>
        </div>

        <!-- Sekretaris -->
        <div
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: 120 } }"
          class="glass-gradient rounded-2xl p-5 flex items-center gap-4"
        >
          <img :src="sekretaris.foto_url || placeholder(sekretaris.nama)" :alt="`Foto ${sekretaris.nama}`" class="h-20 w-20 shrink-0 rounded-full object-cover border border-border" loading="lazy" />
          <div>
            <p class="flex items-center gap-1.5 font-display font-semibold text-ink"><FileText :size="16" class="text-brand-blue" /> {{ sekretaris.nama }}</p>
            <p class="text-sm text-ink-soft">{{ sekretaris.jabatan }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Anggota Dosen — carousel auto-slide 2 card -->
    <section class="mx-auto max-w-5xl px-4 pb-10 md:px-6">
      <h3 class="font-display text-lg font-bold text-ink">Anggota Dosen & Tendik</h3>
      <div class="mt-4">
        <p v-if="loading" class="text-sm text-muted">Memuat…</p>
        <AutoCarousel v-else :items="dosen.map(d => ({ nama: d.nama, jabatan: d.jabatan, foto_url: d.foto_url }))" :visible-count="2" />
      </div>
    </section>

    <!-- Anggota Mahasiswa — sama, data terpisah -->
    <section class="mx-auto max-w-5xl px-4 pb-16 md:px-6">
      <h3 class="font-display text-lg font-bold text-ink">Anggota Mahasiswa</h3>
      <div class="mt-4">
        <p v-if="loading" class="text-sm text-muted">Memuat…</p>
        <AutoCarousel v-else :items="mahasiswa.map(m => ({ nama: m.nama, prodi: m.prodi, foto_url: m.foto_url }))" :visible-count="2" />
      </div>
    </section>
  </div>
</template>
