<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import Button from '@/components/ui/Button.vue'

const menuOpen = ref(false)
const scrollProgress = ref(0)
function onScroll() {
  const h = document.documentElement
  const max = h.scrollHeight - h.clientHeight
  scrollProgress.value = max > 0 ? (h.scrollTop / max) * 100 : 0
}
onMounted(() => window.addEventListener('scroll', onScroll, { passive: true }))
onUnmounted(() => window.removeEventListener('scroll', onScroll))

const links = [
  { to: '/', label: 'Beranda' },
  { to: '/tentang', label: 'Tentang' },
  { to: '/alur', label: 'Alur Pelaporan' },
  { to: '/unduhan', label: 'Unduhan' },
  { to: '/berita', label: 'Berita' },
  { to: '/kontak', label: 'Kontak' },
]
</script>

<template>
  <a
    href="#main"
    class="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-md focus:bg-white focus:px-4 focus:py-2 focus:text-sm focus:font-medium focus:text-link focus:ring-2 focus:ring-link"
  >
    Lewati ke konten utama
  </a>

  <div class="pointer-events-none fixed left-0 top-0 z-[60] h-0.5 w-full origin-left bg-brand-blue transition-[transform] duration-150" :style="{ transform: `scaleX(${scrollProgress/100})` }" aria-hidden="true" />

  <header class="glass sticky top-0 z-40">
    <nav class="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3 md:px-6" aria-label="Utama">
      <RouterLink to="/" class="flex items-center gap-3 font-display font-bold text-ink">
        <img src="/brand/logo.webp" alt="Logo Satuan Tugas PPKPT Universitas Adzkia" class="h-9 w-9 shrink-0 object-contain" width="36" height="36" />
        <span class="hidden flex-col leading-tight sm:flex">
          <span class="text-sm font-bold tracking-tight">Satuan Tugas PPKPT</span>
          <span class="text-xs font-medium text-ink-soft">Universitas Adzkia</span>
        </span>
        <span class="flex flex-col leading-tight sm:hidden">
          <span class="text-sm font-bold">Satgas PPKPT</span>
          <span class="text-xs font-medium text-ink-soft">Adzkia</span>
        </span>
      </RouterLink>

      <div class="hidden items-center gap-6 md:flex">
        <RouterLink
          v-for="l in links"
          :key="l.to"
          :to="l.to"
          class="text-sm font-medium text-ink-soft transition-colors hover:text-brand-blue"
          active-class="text-brand-blue"
        >
          {{ l.label }}
        </RouterLink>
        <Button to="/aduan" class="ml-2">Buat Aduan</Button>
      </div>

      <button
        class="flex h-11 w-11 items-center justify-center rounded-md text-ink md:hidden"
        aria-label="Buka menu"
        aria-controls="mobile-menu"
        :aria-expanded="menuOpen"
        @click="menuOpen = !menuOpen"
      >
        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
    </nav>

    <transition name="slide">
      <div
        v-show="menuOpen"
        id="mobile-menu"
        class="glass border-t border-white/40 md:hidden"
      >
        <div class="grid gap-1 px-4 py-3">
          <RouterLink
            v-for="l in links"
            :key="l.to"
            :to="l.to"
            class="rounded-md px-3 py-2.5 text-sm font-medium text-ink-soft hover:bg-white/60"
            active-class="text-brand-blue"
            @click="menuOpen = false"
          >
            {{ l.label }}
          </RouterLink>
          <Button to="/aduan" class="mt-2" @click="menuOpen = false">Buat Aduan</Button>
        </div>
      </div>
    </transition>
  </header>

    <main id="main" class="min-h-dvh">
    <RouterView />
  </main>

  <footer class="border-t border-border bg-surface">
    <div class="mx-auto max-w-6xl px-4 py-10 md:px-6">
      <div class="grid gap-8 md:grid-cols-3">
        <div>
          <div class="flex items-center gap-3">
            <img src="/brand/logo.webp" alt="Logo Satuan Tugas PPKPT Universitas Adzkia" class="h-10 w-10 shrink-0 object-contain" width="40" height="40" />
            <div class="leading-tight">
              <p class="font-display text-sm font-bold text-ink">Satuan Tugas PPKPT</p>
              <p class="text-xs font-medium text-ink-soft">Universitas Adzkia</p>
            </div>
          </div>
          <p class="mt-3 text-sm text-muted">SK Rektor No. 191/UA/Kep/2024 · Sekretariat Lantai 2 Gedung Lama</p>
        </div>
        <div>
          <p class="text-sm font-semibold text-ink">Tautan</p>
          <ul class="mt-3 grid gap-2 text-sm">
            <li v-for="l in links" :key="l.to">
              <RouterLink :to="l.to" class="text-link hover:underline">{{ l.label }}</RouterLink>
            </li>
          </ul>
        </div>
        <div>
          <p class="text-sm font-semibold text-ink">Kontak</p>
          <p class="mt-3 text-sm text-muted">
            Jl. Taratak Paneh No. 7, Korong Gadang, Kuranji, Padang<br />
            Telp/Faks (0751) 497105 · informasiadzkia@gmail.com<br />
            Sekretariat: Lantai 2 Gedung Lama
          </p>
          <RouterLink to="/admin/login" class="mt-4 inline-block text-xs text-muted underline-offset-2 hover:text-ink-soft hover:underline">
            Login admin
          </RouterLink>
        </div>
      </div>

      <div class="mt-10 flex flex-wrap items-center justify-center gap-6 border-t border-border pt-6">
        <img src="/brand/footer-2.webp" alt="Logo mitra 2" class="h-10 w-auto object-contain md:h-11" loading="lazy" />
        <img src="/brand/footer-3.webp" alt="Logo mitra 3" class="h-10 w-auto object-contain md:h-11" loading="lazy" />
      </div>
      <p class="mt-6 text-center text-xs text-muted">© {{ new Date().getFullYear() }} Satuan Tugas PPKPT Universitas Adzkia. Hak cipta dilindungi.</p>
    </div>
  </footer>
</template>

<style scoped>
.slide-enter-active, .slide-leave-active { transition: opacity 0.25s ease, transform 0.25s var(--ease-out-soft); }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-8px); }
</style>