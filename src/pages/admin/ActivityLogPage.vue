<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const logs = ref<{ id: number; actor_id: string | null; action: string; entity: string; entity_id: string | null; created_at: string }[]>([])
const loading = ref(true)
const err = ref('')

onMounted(async () => {
  const { data, error } = await supabase.from('activity_log').select('id,actor_id,action,entity,entity_id,created_at').order('created_at', { ascending: false }).limit(50)
  if (error) err.value = error.message
  else logs.value = (data ?? []) as typeof logs.value
  loading.value = false
})
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Log Aktivitas</h1>
    <p class="mt-1 text-sm text-ink-soft">Riwayat mutasi penting (dokumen & post). Maksimal 50 terbaru.</p>
    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>
    <div v-if="loading" class="mt-6 py-10 text-center text-muted">Memuat…</div>
    <div v-else class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted"><tr><th class="px-4 py-3">Waktu</th><th class="px-4 py-3">Aksi</th><th class="px-4 py-3">Entitas</th><th class="px-4 py-3">Actor</th></tr></thead>
        <tbody class="divide-y divide-border">
          <tr v-for="l in logs" :key="l.id"><td class="px-4 py-3 text-xs text-muted">{{ new Date(l.created_at).toLocaleString('id-ID') }}</td><td class="px-4 py-3 text-ink">{{ l.action }}</td><td class="px-4 py-3 text-ink-soft">{{ l.entity }}<span class="text-muted"> · {{ l.entity_id?.slice(0,8) ?? '-' }}</span></td><td class="px-4 py-3 text-xs text-muted">{{ l.actor_id?.slice(0,8) ?? '-' }}</td></tr>
        </tbody>
      </table>
      <p v-if="!logs.length" class="p-6 text-center text-sm text-muted">Belum ada aktivitas.</p>
    </div>
  </div>
</template>