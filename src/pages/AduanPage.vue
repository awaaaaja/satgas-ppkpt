<script setup lang="ts">
import { ref } from 'vue'
import { createTicket, getTicketStatus, type TicketStatus } from '@/composables/useTickets'

const mode = ref<'create' | 'check'>('create')
const loading = ref(false)
const error = ref('')

const form = ref({ title: '', description: '', category: 'umum', reporterName: '', reporterContact: '' })

const created = ref<{ ticket_number: string; access_token: string } | null>(null)
const checkNumber = ref('')
const checkToken = ref('')
const checkResult = ref<TicketStatus | null>(null)

const categories = [
  { value: 'umum', label: 'Umum' },
  { value: 'preventif', label: 'Preventif' },
  { value: 'intervensi', label: 'Intervensi' },
  { value: 'advokasi', label: 'Advokasi & Hukum' },
]

async function submitCreate() {
  error.value = ''
  if (!form.value.title.trim() || !form.value.description.trim()) {
    error.value = 'Judul dan uraian aduan wajib diisi.'
    return
  }
  loading.value = true
  try {
    created.value = await createTicket({
      title: form.value.title.trim(),
      description: form.value.description.trim(),
      category: form.value.category,
      reporterName: form.value.reporterName.trim(),
      reporterContact: form.value.reporterContact.trim(),
    })
    localStorage.setItem(
      `ticket:${created.value.ticket_number}`,
      created.value.access_token,
    )
  } catch (e) {
    error.value = 'Gagal mengirim aduan. Silakan coba lagi.'
  } finally {
    loading.value = false
  }
}

async function submitCheck() {
  error.value = ''
  if (!checkNumber.value.trim() || !checkToken.value.trim()) {
    error.value = 'Nomor tiket dan token wajib diisi.'
    return
  }
  loading.value = true
  try {
    checkResult.value = await getTicketStatus(
      checkNumber.value.trim().toUpperCase(),
      checkToken.value.trim(),
    )
    if (!checkResult.value) error.value = 'Tiket tidak ditemukan atau token salah.'
  } catch (e) {
    error.value = 'Gagal memeriksa tiket. Silakan coba lagi.'
  } finally {
    loading.value = false
  }
}

const statusLabel: Record<string, string> = {
  diterima: 'Diterima',
  ditinjau: 'Sedang Ditinjau',
  diproses: 'Diproses',
  selesai: 'Selesai',
  ditolak: 'Ditolak',
}
</script>

<template>
  <main class="brand-gradient-bg min-h-dvh px-4 py-10">
    <div v-motion :initial="{ opacity: 0, y: 16 }" :enter="{ opacity: 1, y: 0, transition: { duration: 500 } }" class="mx-auto max-w-2xl">
      <nav class="mb-8 text-sm">
        <RouterLink to="/" class="font-medium text-link hover:underline">← Beranda</RouterLink>
      </nav>

      <h1 class="font-display text-2xl font-bold text-ink md:text-3xl">Layanan Aduan Satgas PPKPT</h1>
      <p class="mt-2 text-sm text-ink-soft md:text-base">
        Sampaikan aduan atau laporan secara tertulis. Anda tidak perlu masuk akun.
        Setelah dikirim, Anda mendapat nomor tiket untuk memantau perkembangan.
      </p>

      <div class="mt-6 flex gap-2">
        <button
          class="rounded-md px-4 py-2 text-sm font-medium transition-colors"
          :class="mode === 'create' ? 'bg-brand-blue text-white' : 'glass text-ink-soft'"
          @click="mode = 'create'"
        >
          Buat Aduan
        </button>
        <button
          class="rounded-md px-4 py-2 text-sm font-medium transition-colors"
          :class="mode === 'check' ? 'bg-brand-blue text-white' : 'glass text-ink-soft'"
          @click="mode = 'check'"
        >
          Cek Status Tiket
        </button>
      </div>

      <section v-if="mode === 'create'" class="glass-gradient mt-6 rounded-2xl p-6 md:p-8">
      <div v-if="created" class="rounded-md bg-brand-blue-soft p-4">
        <p class="font-semibold text-link">Aduan terkirim. Simpan data berikut untuk cek status:</p>
        <p class="mt-2 text-sm">Nomor tiket: <strong>{{ created.ticket_number }}</strong></p>
        <p class="text-sm">Token akses: <strong>{{ created.access_token }}</strong></p>
        <button
          class="mt-3 rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white"
          @click="mode = 'check'; checkNumber = created.ticket_number; checkToken = created.access_token"
        >
          Cek Status Sekarang
        </button>
      </div>

      <form v-else @submit.prevent="submitCreate" class="grid gap-4">
        <label class="grid gap-1">
          <span class="text-sm font-medium text-ink">Judul aduan *</span>
          <input
            v-model.trim="form.title"
            name="title"
            required
            class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
            placeholder="Ringkasan singkat aduan"
          />
        </label>

        <label class="grid gap-1">
          <span class="text-sm font-medium text-ink">Kategori</span>
          <select
            v-model="form.category"
            name="category"
            class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
          >
            <option v-for="c in categories" :key="c.value" :value="c.value">{{ c.label }}</option>
          </select>
        </label>

        <label class="grid gap-1">
          <span class="text-sm font-medium text-ink">Uraian aduan *</span>
          <textarea
            v-model.trim="form.description"
            name="description"
            required
            rows="6"
            class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink focus:outline-2 focus:outline-link"
            placeholder="Jelaskan kronologi atau hal yang ingin disampaikan"
          ></textarea>
        </label>

        <div class="grid gap-4 sm:grid-cols-2">
          <label class="grid gap-1">
            <span class="text-sm font-medium text-ink">Nama (opsional)</span>
            <input
              v-model.trim="form.reporterName"
              name="reporter_name"
              class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
            />
          </label>
          <label class="grid gap-1">
            <span class="text-sm font-medium text-ink">Kontak (opsional)</span>
            <input
              v-model.trim="form.reporterContact"
              name="reporter_contact"
              class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
            />
          </label>
        </div>

        <p v-if="error" class="text-sm text-danger" role="alert">{{ error }}</p>

        <button
          type="submit"
          :disabled="loading"
          class="rounded-md bg-brand-blue px-5 py-2.5 font-medium text-white transition-transform active:scale-98 disabled:opacity-60"
        >
          {{ loading ? 'Mengirim…' : 'Kirim Aduan' }}
        </button>
      </form>

      <p class="mt-4 rounded-md bg-white/70 p-3 text-xs leading-relaxed text-ink-soft ring-1 ring-border">
        Catatan: Layanan ini adalah kanal administrasi dan informasi awal. Untuk kondisi darurat atau
        mendesak yang membutuhkan penanganan segera, hubungi kanal resmi kampus yang berlaku.
      </p>
    </section>

    <section v-else class="glass-gradient mt-6 rounded-2xl p-6 md:p-8">
      <form @submit.prevent="submitCheck" class="grid gap-4">
        <label class="grid gap-1">
          <span class="text-sm font-medium text-ink">Nomor tiket</span>
          <input
            v-model.trim="checkNumber"
            name="check_number"
            required
            class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
            placeholder="ADZ-2026-0001"
          />
        </label>
        <label class="grid gap-1">
          <span class="text-sm font-medium text-ink">Token akses</span>
          <input
            v-model.trim="checkToken"
            name="check_token"
            required
            class="rounded-md border border-border bg-white px-3 py-2 text-sm text-ink"
            placeholder="Salin token dari bukti pengiriman"
          />
        </label>

        <p v-if="error" class="text-sm text-danger" role="alert">{{ error }}</p>

        <button
          type="submit"
          :disabled="loading"
          class="rounded-md bg-brand-blue px-5 py-2.5 font-medium text-white transition-transform active:scale-98 disabled:opacity-60"
        >
          {{ loading ? 'Memeriksa…' : 'Cek Status' }}
        </button>
      </form>

      <div v-if="checkResult" class="mt-6 rounded-md bg-white/80 p-4">
        <p class="font-semibold text-link">{{ checkResult.ticket_number }}</p>
        <p class="mt-1 text-sm font-medium text-ink">{{ checkResult.title }}</p>
        <p class="mt-1 text-sm text-ink-soft">
          Status: <strong>{{ statusLabel[checkResult.status] ?? checkResult.status }}</strong>
          · Prioritas: {{ checkResult.priority }}
        </p>
        <ul v-if="checkResult.updates.length" class="mt-4 space-y-2 border-t border-border pt-3">
          <li v-for="(u, i) in checkResult.updates" :key="i" class="text-sm text-ink-soft">
            <span class="font-medium text-ink">{{ statusLabel[u.status_to ?? ''] ?? u.status_to ?? '' }}</span>
            <span class="text-muted"> · {{ new Date(u.created_at).toLocaleString('id-ID') }}</span>
          </li>
        </ul>
      </div>
    </section>
  </div>
  </main>
</template>