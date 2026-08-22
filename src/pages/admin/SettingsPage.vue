<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const rows = ref<{ key: string; value: unknown }[]>([])
const loading = ref(true)
const err = ref('')
const nKey = ref('')
const nVal = ref('')

onMounted(load)
async function load() {
  loading.value = true
  const { data, error } = await supabase.from('settings').select('key,value').order('key')
  if (error) err.value = error.message
  else rows.value = (data ?? []) as typeof rows.value
  loading.value = false
}
async function save() {
  if (!nKey.value.trim()) { err.value = 'Key wajib diisi.'; return }
  let v: unknown
  try { v = JSON.parse(nVal.value) } catch { v = nVal.value }
  const { error } = await supabase.from('settings').upsert({ key: nKey.value.trim(), value: v as never })
  if (error) err.value = error.message
  else { nKey.value = ''; nVal.value = ''; await load() }
}
async function remove(k: string) {
  if (!confirm(`Hapus setting "${k}"?`)) return
  const { error } = await supabase.from('settings').delete().eq('key', k)
  if (error) err.value = error.message
  else await load()
}
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Settings</h1>
    <p class="mt-1 text-sm text-ink-soft">Kelola pengaturan situs (alamat, kontak, teks hero, dll). Value disimpan sebagai JSON.</p>
    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>

    <form @submit.prevent="save" class="mt-6 flex flex-wrap gap-3 rounded-xl bg-white p-4 ring-1 ring-border">
      <input v-model.trim="nKey" name="key" placeholder="key (mis. site.heroTitle)" class="flex-1 rounded-md border border-border px-3 py-2 text-sm" />
      <input v-model="nVal" name="value" placeholder='value JSON atau teks (mis. "Universitas Adzkia")' class="flex-[2] rounded-md border border-border px-3 py-2 text-sm" />
      <button type="submit" class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white">Simpan</button>
    </form>

    <div v-if="loading" class="mt-6 py-10 text-center text-muted">Memuat…</div>
    <div v-else class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted"><tr><th class="px-4 py-3">Key</th><th class="px-4 py-3">Value</th><th class="px-4 py-3">Aksi</th></tr></thead>
        <tbody class="divide-y divide-border">
          <tr v-for="r in rows" :key="r.key"><td class="px-4 py-3 font-medium text-ink">{{ r.key }}</td><td class="px-4 py-3 text-ink-soft max-w-md truncate">{{ JSON.stringify(r.value) }}</td><td class="px-4 py-3"><button @click="remove(r.key)" class="text-xs font-medium text-danger hover:underline">Hapus</button></td></tr>
        </tbody>
      </table>
      <p v-if="!rows.length" class="p-6 text-center text-sm text-muted">Belum ada pengaturan.</p>
    </div>
  </div>
</template>