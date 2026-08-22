<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const { profile, getProfile } = useAuth()

const counts = ref({ documents: 0, posts: 0, tickets: 0, messages: 0 })
const logs = ref<{ action: string; entity: string; created_at: string }[]>([])

onMounted(async () => {
  await getProfile()
  const tables = ['documents', 'posts', 'tickets', 'contact_messages'] as const
  const entries = await Promise.all(
    tables.map(async (t) => {
      const { count } = await supabase.from(t).select('*', { count: 'exact', head: true })
      return [t, count ?? 0] as const
    })
  )
  counts.value = Object.fromEntries(entries) as typeof counts.value

  const { data } = await supabase
    .from('activity_log')
    .select('action,entity,created_at')
    .order('created_at', { ascending: false })
    .limit(8)
  logs.value = (data ?? []) as typeof logs.value
})

const label: Record<string, string> = {
  documents: 'Dokumen',
  posts: 'Berita',
  tickets: 'Aduan/Tiket',
  messages: 'Pesan kontak',
}
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Dashboard</h1>
    <p class="mt-1 text-sm text-ink-soft">Selamat datang, {{ profile?.full_name ?? 'Admin' }} ({{ profile?.role ?? '…' }}).</p>

    <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <div v-for="(v, k) in counts" :key="k" class="rounded-xl bg-white p-5 ring-1 ring-border">
        <p class="text-3xl font-bold text-brand-blue">{{ v }}</p>
        <p class="mt-1 text-sm text-ink-soft">{{ label[k] }}</p>
      </div>
    </div>

    <section class="mt-8">
      <h2 class="font-display text-lg font-semibold text-ink">Aktivitas Terbaru</h2>
      <div v-if="logs.length" class="mt-3 overflow-hidden rounded-xl bg-white ring-1 ring-border">
        <table class="w-full text-left text-sm">
          <tbody class="divide-y divide-border">
            <tr v-for="(l, i) in logs" :key="i">
              <td class="px-4 py-2.5 text-ink">{{ l.action }} {{ l.entity }}</td>
              <td class="px-4 py-2.5 text-xs text-muted">
                {{ new Date(l.created_at).toLocaleString('id-ID') }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-else class="mt-3 rounded-xl bg-white p-5 text-sm text-muted ring-1 ring-border">Belum ada aktivitas.</p>
    </section>
  </div>
</template>