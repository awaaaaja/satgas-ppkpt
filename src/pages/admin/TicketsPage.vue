<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuth, getSession } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import {
  listTickets,
  updateTicket,
  addTicketUpdate,
  type Ticket,
} from '@/composables/useTickets'

const { session, signOut } = useAuth()
const tickets = ref<Ticket[]>([])
const loading = ref(true)
const error = ref('')
const filter = ref('semua')
const note = ref('')
const selected = ref<Ticket | null>(null)

const staff = ref(false)

onMounted(async () => {
  const s = await getSession()
  if (s) {
    const { data } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', s.user.id)
      .single()
    staff.value = !!data && ['editor', 'admin', 'superadmin'].includes(data.role)
  }
  await load()
})

const filtered = computed(() =>
  filter.value === 'semua'
    ? tickets.value
    : tickets.value.filter((t) => t.status === filter.value),
)

async function load() {
  loading.value = true
  error.value = ''
  try {
    tickets.value = await listTickets()
  } catch (e) {
    error.value = 'Gagal memuat tiket.'
  } finally {
    loading.value = false
  }
}

const statuses = ['diterima', 'ditinjau', 'diproses', 'selesai', 'ditolak']
const statusLabel: Record<string, string> = {
  diterima: 'Diterima',
  ditinjau: 'Sedang Ditinjau',
  diproses: 'Diproses',
  selesai: 'Selesai',
  ditolak: 'Ditolak',
}

async function setStatus(status: string) {
  if (!selected.value) return
  try {
    await updateTicket(selected.value.id, { status })
    await load()
    selected.value = tickets.value.find((t) => t.id === selected.value?.id) ?? null
    note.value = ''
  } catch (e) {
    error.value = 'Gagal mengubah status.'
  }
}

async function addNote() {
  if (!selected.value || !note.value.trim()) return
  try {
    await addTicketUpdate(selected.value.id, note.value.trim())
    note.value = ''
    await load()
    selected.value = tickets.value.find((t) => t.id === selected.value?.id) ?? null
  } catch (e) {
    error.value = 'Gagal menambah catatan.'
  }
}
</script>

<template>
  <div class="mx-auto max-w-5xl px-4 py-8">
    <div v-motion :initial="{ opacity: 0, y: 12 }" :enter="{ opacity: 1, y: 0, transition: { duration: 400 } }" class="glass-gradient rounded-2xl px-6 py-5">
      <div class="flex items-center justify-between gap-4">
        <h1 class="font-display text-2xl font-bold text-ink">Kelola Tiket Aduan</h1>
        <div class="flex items-center gap-3 text-sm">
          <span v-if="session" class="text-ink-soft">{{ session.user.email }}</span>
          <button class="text-link hover:underline" @click="signOut">Keluar</button>
        </div>
      </div>

      <p v-if="!staff" class="mt-3 rounded-md bg-warning/10 p-3 text-sm text-warning">
        Akun Anda tidak memiliki akses kelola tiket.
      </p>
    </div>

    <div class="mb-4 mt-4 flex flex-wrap gap-2">
      <button
        v-for="f in ['semua', ...statuses]"
        :key="f"
        class="rounded-full px-3 py-1 text-sm font-medium transition-colors"
        :class="filter === f ? 'bg-brand-blue text-white' : 'bg-surface text-ink-soft ring-1 ring-border'"
        @click="filter = f"
      >
        {{ f === 'semua' ? 'Semua' : statusLabel[f] }}
      </button>
    </div>

    <p v-if="error" class="mb-4 text-sm text-danger" role="alert">{{ error }}</p>

    <div v-if="loading" class="py-10 text-center text-muted">Memuat…</div>

    <div v-else class="overflow-x-auto rounded-lg bg-surface shadow-sm ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="border-b border-border text-xs uppercase tracking-wide text-muted">
          <tr>
            <th class="px-4 py-3">Nomor</th>
            <th class="px-4 py-3">Judul</th>
            <th class="px-4 py-3">Kategori</th>
            <th class="px-4 py-3">Status</th>
            <th class="px-4 py-3">Prioritas</th>
            <th class="px-4 py-3">Dibuat</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-border">
          <tr
            v-for="t in filtered"
            :key="t.id"
            class="cursor-pointer hover:bg-bg"
            @click="selected = t"
          >
            <td class="px-4 py-3 font-medium text-link">{{ t.ticket_number }}</td>
            <td class="px-4 py-3 text-ink">{{ t.title }}</td>
            <td class="px-4 py-3 text-ink-soft">{{ t.category }}</td>
            <td class="px-4 py-3">
              <span
                class="rounded-full px-2 py-0.5 text-xs font-medium"
                :class="t.status === 'selesai' ? 'bg-success/10 text-success' : t.status === 'ditolak' ? 'bg-danger/10 text-danger' : 'bg-brand-blue-soft text-link'"
              >
                {{ statusLabel[t.status] }}
              </span>
            </td>
            <td class="px-4 py-3 text-ink-soft">{{ t.priority }}</td>
            <td class="px-4 py-3 text-muted">{{ new Date(t.created_at).toLocaleDateString('id-ID') }}</td>
          </tr>
        </tbody>
      </table>
      <p v-if="!filtered.length" class="p-6 text-center text-muted">Belum ada tiket.</p>
    </div>

    <div
      v-if="selected && staff"
      class="fixed inset-0 z-50 flex items-center justify-center bg-ink/50 p-4"
      @click.self="selected = null"
    >
      <div class="w-full max-w-lg rounded-lg bg-surface p-6 shadow-lg">
        <div class="mb-2 flex items-start justify-between gap-4">
          <div>
            <p class="font-semibold text-link">{{ selected.ticket_number }}</p>
            <p class="font-display text-lg font-bold text-ink">{{ selected.title }}</p>
          </div>
          <button class="text-muted hover:text-ink" @click="selected = null" aria-label="Tutup">✕</button>
        </div>
        <p class="text-sm leading-relaxed text-ink-soft">{{ selected.description }}</p>

        <div class="mt-4 grid gap-2 text-sm">
          <label class="flex items-center justify-between gap-2">
            <span class="text-muted">Status</span>
            <select
              :value="selected.status"
              class="rounded-md border border-border bg-white px-2 py-1"
              @change="setStatus(($event.target as HTMLSelectElement).value)"
            >
              <option v-for="s in statuses" :key="s" :value="s">{{ statusLabel[s] }}</option>
            </select>
          </label>
          <p class="text-xs text-muted">
            Pelapor: {{ selected.reporter_name || 'Anonim' }}
            {{ selected.reporter_contact ? '· ' + selected.reporter_contact : '' }}
          </p>
        </div>

        <div class="mt-4 border-t border-border pt-4">
          <label class="text-sm font-medium text-ink">Catatan perkembangan</label>
          <div class="mt-1 flex gap-2">
            <input
              v-model.trim="note"
              class="flex-1 rounded-md border border-border bg-white px-3 py-2 text-sm"
              placeholder="Tulis catatan untuk pelapor"
            />
            <button
              class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white"
              @click="addNote"
            >
              Tambah
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>