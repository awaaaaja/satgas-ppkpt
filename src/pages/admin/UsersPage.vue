<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const { profile } = useAuth()
const users = ref<{ id: string; full_name: string | null; role: string }[]>([])
const loading = ref(true)
const err = ref('')

onMounted(async () => {
  const { data, error } = await supabase.from('profiles').select('id,full_name,role').order('role')
  if (error) err.value = error.message
  else users.value = (data ?? []) as typeof users.value
  loading.value = false
})

async function setRole(u: { id: string; role: string }, role: string) {
  if (profile.value?.role !== 'superadmin') { err.value = 'Hanya superadmin yang dapat mengubah role.'; return }
  const { error } = await supabase.from('profiles').update({ role }).eq('id', u.id)
  if (error) err.value = error.message
  else u.role = role
}
</script>

<template>
  <div class="max-w-5xl">
    <h1 class="font-display text-2xl font-bold text-ink">Kelola User</h1>
    <p class="mt-1 text-sm text-ink-soft">Hanya superadmin yang dapat mengubah role pengguna.</p>
    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>
    <div v-if="loading" class="mt-6 py-10 text-center text-muted">Memuat…</div>
    <div v-else class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted"><tr><th class="px-4 py-3">Nama</th><th class="px-4 py-3">Role</th><th class="px-4 py-3">Aksi</th></tr></thead>
        <tbody class="divide-y divide-border">
          <tr v-for="u in users" :key="u.id"><td class="px-4 py-3 text-ink">{{ u.full_name ?? u.id.slice(0,8) }}</td><td class="px-4 py-3"><span class="rounded-full bg-surface px-2 py-0.5 text-xs">{{ u.role }}</span></td><td class="px-4 py-3">
            <select :value="u.role" @change="setRole(u, ($event.target as HTMLSelectElement).value)" :disabled="profile?.role !== 'superadmin'" class="rounded-md border border-border px-2 py-1 text-xs">
              <option value="editor">editor</option><option value="admin">admin</option><option value="superadmin">superadmin</option>
            </select>
          </td></tr>
        </tbody>
      </table>
    </div>
  </div>
</template>