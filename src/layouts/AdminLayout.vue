<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, RouterView, useRouter, useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const route = useRoute()
const { profile, signOut } = useAuth()
const open = ref(false)

const nav = [
  { to: { name: 'admin-dashboard' }, label: 'Dashboard' },
  { to: { name: 'admin-satgas' }, label: 'Satgas' },
  { to: { name: 'admin-documents' }, label: 'Dokumen' },
  { to: { name: 'admin-posts' }, label: 'Berita' },
  { to: { name: 'admin-tickets' }, label: 'Aduan/Tiket' },
  { to: { name: 'admin-messages' }, label: 'Pesan' },
  { to: { name: 'admin-settings' }, label: 'Settings' },
  { to: { name: 'admin-users' }, label: 'Users' },
  { to: { name: 'admin-logs' }, label: 'Log' },
]

function isActive(to: object) {
  return route.name === (to as { name: string }).name
}

async function logout() {
  await signOut()
  router.push({ name: 'admin-login' })
}
</script>

<template>
  <div class="min-h-dvh bg-surface">
    <aside class="fixed inset-y-0 left-0 z-40 hidden w-60 flex-col bg-ink px-4 py-6 text-white md:flex">
      <RouterLink to="/admin/dashboard" class="px-2 font-display text-lg font-bold">Satgas Admin</RouterLink>
      <p class="px-2 text-xs text-white/60">Universitas Adzkia</p>

      <nav class="mt-8 grid gap-1">
        <RouterLink
          v-for="n in nav"
          :key="n.label"
          :to="n.to"
          class="rounded-md px-3 py-2 text-sm font-medium"
          :class="isActive(n.to) ? 'bg-brand-blue text-white' : 'text-white/70 hover:bg-white/10 hover:text-white'"
        >
          {{ n.label }}
        </RouterLink>
      </nav>

      <div class="mt-auto grid gap-3">
        <RouterLink to="/" class="text-sm text-white/60 hover:text-white">← Lihat situs publik</RouterLink>
        <div class="rounded-md bg-white/10 p-3 text-sm">
          <p class="font-medium">{{ profile?.full_name ?? 'Pengguna' }}</p>
          <p class="text-xs text-white/60">{{ profile?.role ?? '…' }}</p>
        </div>
        <button type="button" @click="logout" class="rounded-md bg-white/10 px-3 py-2 text-sm font-medium hover:bg-white/20">
          Keluar
        </button>
      </div>
    </aside>

    <header class="sticky top-0 z-30 flex items-center gap-3 border-b border-border bg-surface px-4 py-3 md:hidden">
      <button
        type="button"
        aria-label="Buka menu admin"
        :aria-expanded="open"
        class="rounded-md bg-white px-3 py-1.5 text-sm font-medium ring-1 ring-border"
        @click="open = !open"
      >
        Menu
      </button>
      <p class="font-display text-sm font-bold text-ink">Satgas Admin</p>
      <button type="button" class="ml-auto text-sm text-link" @click="logout">Keluar</button>
    </header>

    <nav v-if="open" class="z-30 grid gap-1 border-b border-border bg-white p-3 md:hidden">
      <RouterLink
        v-for="n in nav"
        :key="n.label"
        :to="n.to"
        class="rounded-md px-3 py-2 text-sm font-medium text-ink"
        :class="isActive(n.to) ? 'bg-brand-blue text-white' : ''"
        @click="open = false"
      >
        {{ n.label }}
      </RouterLink>
    </nav>

    <main class="p-4 md:ml-60 md:p-8">
      <RouterView />
    </main>
  </div>
</template>