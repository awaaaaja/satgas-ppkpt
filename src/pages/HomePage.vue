<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import Button from '@/components/ui/Button.vue'
import Badge from '@/components/ui/Badge.vue'
import SectionHeading from '@/components/ui/SectionHeading.vue'
import { supabase, storageUrl } from '@/lib/supabase'
import { Hand, Brain, Users, ShieldAlert, FileWarning, Scale, Megaphone } from 'lucide-vue-next'

interface Post {
  id: string
  title: string
  excerpt?: string | null
  category?: string | null
  cover_url?: string | null
  published_at?: string | null
}

const posts = ref<Post[]>([])

const divisions = [
  {
    nama: 'Preventif',
    desc: 'Pencegahan kekerasan melalui edukasi, sosialisasi, dan pembangunan budaya kampus yang aman.',
  },
  {
    nama: 'Intervensi',
    desc: 'Penanganan laporan, pendampingan korban, dan pemulihan lingkungan terdampak.',
  },
  {
    nama: 'Advokasi & Hukum',
    desc: 'Pendampingan hukum, fasilitasi penyelesaian, dan advokasi kebijakan.',
  },
]

// Tagline & 6 bentuk kekerasan Permendikbudristek 55/2024
const kekerasan = [
  { icon: Hand, judul: 'Kekerasan Fisik', desc: 'Kontak fisik, penganiayaan, hingga tindakan yang melukai tubuh.' },
  { icon: Brain, judul: 'Kekerasan Psikis', desc: 'Intimidasi, ancaman akademik, manipulasi, dan tekanan psikologis.' },
  { icon: Users, judul: 'Perundungan', desc: 'Bullying, pelecehan verbal, pengucilan, dan kekerasan relasi kuasa.' },
  { icon: ShieldAlert, judul: 'Kekerasan Seksual', desc: 'Pelecehan, eksploitasi, hingga kekerasan seksual, zero tolerance.' },
  { icon: FileWarning, judul: 'Kebijakan yang Mengandung Kekerasan', desc: 'Aturan atau kebijakan yang diskriminatif dan berpotensi menindas.' },
  { icon: Scale, judul: 'Diskriminasi & Intoleransi', desc: 'Diskriminasi gender, disabilitas, SARA, dan intoleransi di kampus.' },
]

const slides = [
  '/storage/v1/object/public/gambar/foto-01.webp',
  '/storage/v1/object/public/gambar/foto-03.webp',
  '/storage/v1/object/public/gambar/foto-06.webp',
]
const slideIdx = ref(0)
let timer: ReturnType<typeof setInterval> | undefined

onMounted(async () => {
  const { data } = await supabase
    .from('posts')
    .select('id,title,excerpt,category,cover_url,published_at')
    .eq('status', 'published')
    .order('published_at', { ascending: false })
    .limit(3)
  posts.value = (data ?? []) as Post[]

  timer = setInterval(() => {
    slideIdx.value = (slideIdx.value + 1) % slides.length
  }, 5000)
})

onUnmounted(() => clearInterval(timer))
</script>

<template>
  <div class="brand-gradient-bg">
    <section class="relative overflow-hidden">
      <div class="absolute inset-0">
        <img
          v-for="(s, i) in slides"
          :key="s"
          :src="storageUrl(s) ?? undefined"
          alt="Dokumentasi kegiatan Satgas PPKPT Universitas Adzkia"
          class="absolute inset-0 h-full w-full object-cover"
          :class="i === slideIdx ? 'opacity-100' : 'opacity-0'"
          style="transition: opacity 1s ease"
        />
        <div class="absolute inset-0 bg-gradient-to-r from-brand-blue/95 via-brand-blue/80 to-brand-blue/40" />
      </div>

      <div class="relative mx-auto grid max-w-6xl items-center gap-10 px-4 py-20 md:px-6 md:py-28">
        <div v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 500 } }" class="max-w-xl">
          <Badge tone="blue" class="mb-4">Permendikbudristek No. 55 Tahun 2024</Badge>
          <h1 class="font-display text-3xl font-bold leading-tight text-white drop-shadow md:text-5xl">
            Kampus yang Aman, <span class="text-white underline decoration-brand-blue-light decoration-4 underline-offset-4">Inklusif</span>, dan Bebas dari Kekerasan
          </h1>
          <p class="mt-4 text-sm text-white/90 md:text-base">
            Satgas Pencegahan dan Penanganan Kekerasan di Perguruan Tinggi (PPKPT) Universitas Adzkia
            hadir untuk melindungi setiap warga kampus.
          </p>
          <div class="mt-6 flex flex-wrap gap-3">
            <Button to="/aduan" variant="danger">Buat Aduan</Button>
            <Button to="/alur" variant="danger">Lihat Alur Pelaporan</Button>
          </div>
        </div>
      </div>

      <div class="absolute bottom-4 left-1/2 flex -translate-x-1/2 gap-2" role="tablist" aria-label="Pilih gambar latar">
        <button
          v-for="(_, i) in slides"
          :key="i"
          type="button"
          class="h-2 w-2 rounded-full transition-all"
          :class="i === slideIdx ? 'w-6 bg-white' : 'bg-white/50'"
          :aria-label="`Gambar ${i + 1}`"
          @click="slideIdx = i"
        />
      </div>
    </section>

    <!-- Tagline + Video -->
    <section class="mx-auto max-w-6xl px-4 py-12 md:px-6">
      <div class="grid gap-8 md:grid-cols-2 md:items-center">
        <div v-motion :initial="{ opacity: 0, x: -16 }" :enter="{ opacity: 1, x: 0, transition: { duration: 500 } }">
          <Badge tone="blue" class="mb-3"><Megaphone :size="14" class="inline" /> Satgas PPKPT Universitas Adzkia</Badge>
          <h2 class="font-display text-2xl font-bold leading-tight text-ink md:text-3xl">
            Lawan Kekerasan,<br /><span class="text-brand-blue">Bangun Kesadaran!</span>
          </h2>
          <p class="mt-3 text-sm leading-relaxed text-ink-soft">
            Satgas PPKPT Universitas Adzkia hadir sebagai garda terdepan mewujudkan kampus yang aman, inklusif, dan bebas dari kekerasan, selaras dengan <strong class="text-ink">Permendikbudristek No. 55 Tahun 2024</strong> dan semangat <em>#KampusAMAN</em>.
            Kami melakukan pencegahan melalui edukasi, sosialisasi, dan kampanye; penanganan melalui pelaporan, pendampingan, dan pemulihan; serta membangun budaya saling menjaga, karena pencegahan lebih baik daripada penanganan.
          </p>
          <p class="mt-3 text-sm leading-relaxed text-ink-soft">
            Laporan ditangani serius, profesional, dan rahasia, berkeadilan bagi korban, berhati-hati, dan zero tolerance terhadap segala bentuk kekerasan.
          </p>
          <div class="mt-5 flex flex-wrap gap-3">
            <Button to="/tentang" variant="outline">Tentang Satgas</Button>
            <Button to="/aduan" variant="danger">Laporkan Sekarang</Button>
          </div>
        </div>

        <!-- Video autoplay dengan frame menarik -->
        <div
          v-motion
          :initial="{ opacity: 0, x: 16 }"
          :enter="{ opacity: 1, x: 0, transition: { duration: 500, delay: 150 } }"
          class="glass-gradient overflow-hidden rounded-2xl p-2 shadow-lg"
        >
          <div class="aspect-video overflow-hidden rounded-xl bg-ink">
            <iframe
              src="https://www.youtube-nocookie.com/embed/n5SXW_uHuZA?autoplay=1&mute=1&playsinline=1&rel=0&modestbranding=1"
              title="Video Satgas PPKPT"
              class="h-full w-full"
              allow="autoplay; encrypted-media; picture-in-picture"
              allowfullscreen
              loading="lazy"
              referrerpolicy="strict-origin-when-cross-origin"
            ></iframe>
          </div>
          <p class="mt-2 text-center text-xs text-muted">Video sosialisasi, autoplay muted. Sumber: YouTube</p>
        </div>
      </div>
    </section>

    <!-- 6 Bentuk Kekerasan -->
    <section class="mx-auto max-w-6xl px-4 pb-12 md:px-6">
      <SectionHeading heading="Kenali 6 Bentuk Kekerasan" lead="Sesuai Permendikbudristek 55/2024, pahami, cegah, dan berani melapor." />
      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="(k, i) in kekerasan"
          :key="k.judul"
          class="glass-gradient group rounded-2xl p-5 transition-all duration-300 hover:-translate-y-1"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 70 } }"
        >
          <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-blue/10 text-brand-blue transition-colors duration-300 group-hover:bg-brand-blue group-hover:text-white">
            <component :is="k.icon" :size="22" />
          </div>
          <p class="mt-3 font-display text-sm font-bold text-ink">{{ k.judul }}</p>
          <p class="mt-1 text-sm leading-relaxed text-ink-soft">{{ k.desc }}</p>
        </div>
      </div>
    </section>

    <section class="mx-auto max-w-6xl px-4 py-12 md:px-6">
      <div class="grid gap-4 md:grid-cols-3">
        <div
          v-for="(d, i) in divisions"
          :key="d.nama"
          class="glass-gradient rounded-2xl p-5"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 120 } }"
        >
          <p class="font-display font-semibold text-brand-blue">{{ d.nama }}</p>
          <p class="mt-2 text-sm text-ink-soft">{{ d.desc }}</p>
        </div>
      </div>
    </section>

    <section class="mx-auto max-w-6xl px-4 pb-20 md:px-6">
      <div class="flex items-end justify-between gap-4">
        <h2 class="font-display text-2xl font-bold text-ink">Berita Terbaru</h2>
        <RouterLink to="/berita" class="text-sm font-medium text-link hover:underline">Semua berita →</RouterLink>
      </div>

      <div v-if="posts.length" class="mt-6 grid gap-4 md:grid-cols-3">
        <RouterLink
          v-for="(p, i) in posts"
          :key="p.id"
          :to="`/berita/${p.id}`"
          class="glass-gradient group overflow-hidden rounded-2xl transition-transform duration-150 hover:scale-102"
          v-motion
          :initial="{ opacity: 0, y: 16 }"
          :enter="{ opacity: 1, y: 0, transition: { duration: 400, delay: i * 120 } }"
        >
          <div class="aspect-video overflow-hidden">
            <img
              v-if="p.cover_url"
              :src="storageUrl(p.cover_url) ?? undefined"
              :alt="p.title"
              loading="lazy"
              class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
            <div v-else class="h-full w-full bg-gradient-to-br from-brand-blue to-brand-blue-soft" />
          </div>
          <div class="p-5">
            <div class="flex items-center gap-2">
              <Badge v-if="p.category" tone="blue">{{ p.category }}</Badge>
              <span v-if="p.published_at" class="text-xs text-muted">
                {{ new Date(p.published_at).toLocaleDateString('id-ID') }}
              </span>
            </div>
            <p class="mt-2 font-display font-semibold text-ink">{{ p.title }}</p>
            <p v-if="p.excerpt" class="mt-1 line-clamp-2 text-sm text-ink-soft">{{ p.excerpt }}</p>
          </div>
        </RouterLink>
      </div>

      <div v-else class="glass-gradient mt-6 rounded-2xl p-8 text-center text-sm text-ink-soft">
        Belum ada berita yang dipublikasikan.
      </div>
    </section>
  </div>
</template>