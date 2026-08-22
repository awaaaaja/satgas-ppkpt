<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

interface Msg {
  id: string
  name: string
  email: string
  message: string
  status: string
  created_at: string
}

const msgs = ref<Msg[]>([])
const loading = ref(true)
const err = ref('')

onMounted(async () => {
  const { data, error } = await supabase.from('contact_messages').select('*').order('created_at', { ascending: false })
  if (error) err.value = error.message
  else msgs.value = (data ?? []) as Msg[]
  loading.value = false
})

async function setStatus(m: Msg, status: string) {
  const { error } = await supabase.from('contact_messages').update({ status }).eq('id', m.id)
  if (error) err.value = error.message
  else m.status = status
}
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Pesan Kontak</h1>
    <p class="mt-1 text-sm text-ink-soft">Daftar pesan dari form kontak publik (hanya admin).</p>
    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>
    <div v-if="loading" class="mt-8 py-10 text-center text-muted">Memuat…</div>
    <div v-else-if="msgs.length" class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted">
          <tr><th class="px-4 py-3">Nama</th><th class="px-4 py-3">Email</th><th class="px-4 py-3">Pesan</th><th class="px-4 py-3">Status</th><th class="px-4 py-3">Aksi</th></tr>
        </thead>
        <tbody class="divide-y divide-border">
          <tr v-for="m in msgs" :key="m.id">
            <td class="px-4 py-3 text-ink">{{ m.name }}</td>
            <td class="px-4 py-3 text-ink-soft">{{ m.email }}</td>
            <td class="px-4 py-3 text-ink-soft max-w-xs truncate">{{ m.message }}</td>
            <td class="px-4 py-3"><span class="rounded-full bg-surface px-2 py-0.5 text-xs">{{ m.status }}</span></td>
            <td class="px-4 py-3">
              <button v-if="m.status !== 'read'" @click="setStatus(m,'read')" class="text-xs font-medium text-link hover:underline">Tandai dibaca</button>
              <button v-if="m.status !== 'archived'" @click="setStatus(m,'archived')" class="ml-2 text-xs font-medium text-muted hover:underline">Arsip</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-else class="mt-6 rounded-xl bg-white p-6 text-center text-sm text-muted ring-1 ring-border">Belum ada pesan.</p>
  </div>
</template>