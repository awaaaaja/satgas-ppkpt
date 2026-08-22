<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

// Tipe item generik untuk carousel — foto opsional, fallback placeholder islami (inisial)
export interface CarouselItem {
  nama: string
  jabatan?: string
  prodi?: string
  foto_url?: string | null
  // untuk key
  id?: string | number
}

const props = withDefaults(
  defineProps<{
    items: CarouselItem[]
    visibleCount?: number
    intervalMs?: number
  }>(),
  {
    visibleCount: 2,
    intervalMs: 3500,
  }
)

// helper inisial — dipakai untuk placeholder islami (tanpa foto wajah, menjaga aurat)
function initials(nama: string) {
  return nama
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase() ?? '')
    .join('')
}

// placeholder islami open-source — foto modest dari Unsplash/Pexels (lisensi bebas, CC0)
// Jika foto_url kosong, pakai foto islami sesuai nama (hijab untuk perempuan, peci/koko untuk laki-laki)
// Sumber open-source: Unsplash (unsplash.com/license) & Pexels (pexels.com/license) — gratis, islami (hijab/modest)
const islamicPlaceholders: Record<string, string> = {
  'Muzayyanah, Lc., M.A.': 'https://images.unsplash.com/photo-1526510747491-58f928ec870f?w=400&h=400&fit=crop&crop=face',
  'Fadilla Windryani, S.Pd.': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=400&fit=crop&crop=face',
  'Elva Zuleni, M.Pd.': 'https://images.unsplash.com/photo-1534751516642-a1af1ef26a56?w=400&h=400&fit=crop&crop=face',
  'Ringgi Rahmat Fitra, M.Pd.': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
  'Mutia Jawaz Muslim, M.H.': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
  'Nicky Nia Gustriani, S.Ip.': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
  'Nala Fratika Sari': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&h=400&fit=crop&crop=face',
  'Nurrahmi Juwita': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=400&h=400&fit=crop&crop=face',
  'Eni Azzahra': 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=400&h=400&fit=crop&crop=face',
  'Haikal Fatwa Rachmansyah': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
  'Muhammad Fajri': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop&crop=face',
}
function placeholderUrl(nama: string) {
  // pakai mapping islami jika ada, fallback ke placehold.co inisial (tetap islami — tanpa wajah)
  if (islamicPlaceholders[nama]) return islamicPlaceholders[nama]
  const t = initials(nama)
  return `https://placehold.co/400x400/e8f1f9/1a6bb5?text=${encodeURIComponent(t)}`
}

// Responsive: desktop pakai visibleCount, mobile pakai 1 card
// Bisa juga dikontrol via props dari parent (mis. :visible-count="isMobile ? 1 : 2")
const isMobile = ref(false)
function checkMobile() {
  if (typeof window !== 'undefined') isMobile.value = window.innerWidth < 640
}

// jumlah card terlihat efektif
const effectiveVisible = computed(() => (isMobile.value ? 1 : props.visibleCount))

// chunk items jadi halaman (2 card per slide)
const pages = computed(() => {
  const perPage = effectiveVisible.value
  const out: CarouselItem[][] = []
  for (let i = 0; i < props.items.length; i += perPage) out.push(props.items.slice(i, i + perPage))
  return out
})

const totalPages = computed(() => pages.value.length)

// index halaman aktif
const index = ref(0)

// auto-slide pakai setInterval — di-clear saat unmount
let timer: ReturnType<typeof setInterval> | undefined
let startX = 0
function onTouchStart(e: TouchEvent) { startX = e.touches[0].clientX; if (timer) clearInterval(timer) }
function onTouchEnd(e: TouchEvent) {
  const dx = e.changedTouches[0].clientX - startX
  if (Math.abs(dx) > 40) {
    if (dx < 0) index.value = (index.value + 1) % totalPages.value
    else index.value = (index.value - 1 + totalPages.value) % totalPages.value
  }
  // restart auto-slide
  if (timer) clearInterval(timer)
  timer = setInterval(() => {
    if (totalPages.value <= 1) return
    index.value = (index.value + 1) % totalPages.value
  }, props.intervalMs)
}

// jika jumlah halaman berubah (mis. responsive 2→1), reset index agar tidak out-of-range
watch(totalPages, (n) => {
  if (index.value >= n) index.value = 0
})

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  // auto-slide ringan, pause jika user prefers-reduced-motion
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  if (!reduceMotion) {
    timer = setInterval(() => {
      if (totalPages.value <= 1) return
      index.value = (index.value + 1) % totalPages.value
    }, props.intervalMs)
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
  if (timer) clearInterval(timer)
})

// offset untuk transform — persen relatif terhadap track (track = totalPages*100% viewport)
// jadi geser 1 halaman = 100/totalPages % dari track
const offsetPercent = computed(() => {
  if (totalPages.value === 0) return 0
  return -(index.value * 100 / totalPages.value)
})
</script>

<template>
  <!-- viewport: sembunyikan overflow, ringan tanpa perspective, swipe di mobile -->
  <div class="carousel-viewport" @touchstart.passive="onTouchStart" @touchend.passive="onTouchEnd">
    <!-- track: geser pakai translateX, transisi 0.6s ease-in-out -->
    <div
      class="carousel-track"
      :style="{ width: `${totalPages * 100}%`, transform: `translateX(${offsetPercent}%)` }"
    >
      <!-- setiap page berisi 1-2 card -->
      <div v-for="(page, pIdx) in pages" :key="pIdx" class="carousel-page" :style="{ flex: `0 0 ${100 / totalPages}%` }">
        <div v-for="item in page" :key="(item.id ?? item.nama)" class="carousel-card glass-gradient">
          <!-- frame sangat menarik: gradient border + shadow -->
          <div class="carousel-img-wrap">
            <img
              :src="item.foto_url || placeholderUrl(item.nama)"
              :alt="`Foto ${item.nama}`"
              class="carousel-img"
              loading="lazy"
              width="400"
              height="400"
            />
          </div>
          <div class="carousel-body">
            <p class="carousel-nama">{{ item.nama }}</p>
            <p v-if="item.jabatan" class="carousel-meta">{{ item.jabatan }}</p>
            <p v-if="item.prodi" class="carousel-meta">{{ item.prodi }}</p>
          </div>
        </div>
        <!-- isi dengan spacer jika page terakhir tidak penuh (biar rata) -->
        <div v-for="n in Math.max(0, effectiveVisible - page.length)" :key="`spacer-${n}`" class="carousel-card carousel-card--spacer" aria-hidden="true" />
      </div>
    </div>

    <!-- indikator dots — klik untuk pindah, tetap tanpa panah -->
    <div v-if="totalPages > 1" class="carousel-dots" role="tablist">
      <button
        v-for="(_, i) in totalPages"
        :key="i"
        type="button"
        class="carousel-dot"
        :class="{ 'is-active': i === index }"
        :aria-label="`Halaman ${i + 1}`"
        :aria-selected="i === index"
        role="tab"
        @click="index = i"
      />
    </div>
  </div>
</template>

<style scoped>
/* viewport sederhana, tanpa blur berat */
.carousel-viewport {
  overflow: hidden;
  width: 100%;
}

/* track flex, transisi ringan 0.6s ease-in-out, tanpa 3D */
.carousel-track {
  display: flex;
  transition: transform 0.6s ease-in-out;
  will-change: transform;
}

/* setiap page — lebar diatur via inline flex-basis */
.carousel-page {
  display: flex;
  gap: 16px;
  padding: 4px;
  box-sizing: border-box;
  justify-content: center;
}

/* card tidak terlalu lebar — max 300px, tetap ringan */
.carousel-card {
  flex: 0 1 280px;
  max-width: 300px;
  min-width: 0;
  border-radius: 16px;
  padding: 18px 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 12px;
}

/* spacer transparan agar page terakhir tetap rata */
.carousel-card--spacer {
  visibility: hidden;
  pointer-events: none;
  background: transparent;
  border: none;
  box-shadow: none;
}

/* frame sangat menarik — gradient + shadow */
.carousel-img-wrap {
  padding: 4px;
  border-radius: 9999px;
  background: linear-gradient(135deg, var(--color-brand-blue), #d9251b);
  box-shadow: 0 6px 16px rgba(16, 18, 20, 0.12), 0 2px 6px rgba(16, 18, 20, 0.08);
}

.carousel-img {
  width: 128px;
  height: 128px;
  border-radius: 9999px;
  object-fit: cover;
  border: 3px solid #fff;
  display: block;
  background: var(--color-brand-blue-soft);
}

.carousel-body {
  min-width: 0;
}

.carousel-nama {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--color-ink);
  line-height: 1.3;
}

.carousel-meta {
  margin-top: 2px;
  font-size: 0.8rem;
  color: var(--color-ink-soft);
}

/* dots */
.carousel-dots {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-top: 12px;
}

.carousel-dot {
  width: 8px;
  height: 8px;
  border-radius: 9999px;
  background: var(--color-border);
  transition: width 0.3s ease, background 0.3s ease;
  border: none;
  padding: 0;
  cursor: pointer;
  appearance: none;
}

.carousel-dot.is-active {
  width: 20px;
  background: var(--color-brand-blue);
}

/* mobile: jika 1 card, gap tetap */
@media (max-width: 639px) {
  .carousel-page {
    gap: 12px;
  }
}
</style>
