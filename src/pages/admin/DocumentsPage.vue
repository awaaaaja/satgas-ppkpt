<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase, storageUrl } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const { session } = useAuth()

interface Doc {
  id: string
  title: string
  slug: string
  category: string
  description: string | null
  file_url: string
  file_type: string | null
  file_size: number | null
  published_at: string
}

const docs = ref<Doc[]>([])
const loading = ref(true)
const err = ref('')
const editing = ref<Doc | null>(null)
const showForm = ref(false)
const form = ref({
  title: '',
  slug: '',
  category: 'regulasi',
  description: '',
  file: null as File | null,
  published_at: new Date().toISOString().slice(0, 10),
})
const saving = ref(false)

const categories = ['regulasi', 'formulir', 'pedoman', 'kode-etik', 'lainnya']

onMounted(load)

async function load() {
  loading.value = true
  const { data } = await supabase
    .from('documents')
    .select('*')
    .order('published_at', { ascending: false })
  docs.value = (data ?? []) as Doc[]
  loading.value = false
}

function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'dokumen'
}

function openNew() {
  showForm.value = true
  editing.value = null
  form.value = { title: '', slug: '', category: 'regulasi', description: '', file: null, published_at: new Date().toISOString().slice(0, 10) }
}

function openEdit(d: Doc) {
  showForm.value = true
  editing.value = d
  form.value = {
    title: d.title,
    slug: d.slug,
    category: d.category,
    description: d.description ?? '',
    file: null,
    published_at: d.published_at.slice(0, 10),
  }
}

async function uploadFile(): Promise<{ url: string; type: string; size: number } | null> {
  const f = form.value.file
  if (!f) return null
  const name = `${Date.now()}-${f.name.replace(/[^a-z0-9._-]/gi, '_')}`
  const { error } = await supabase.storage.from('documents').upload(name, f)
  if (error) throw error
  return { url: `/storage/v1/object/public/documents/${name}`, type: f.type, size: f.size }
}

async function save() {
  err.value = ''
  if (!form.value.title.trim() || !form.value.slug.trim()) {
    err.value = 'Judul dan slug wajib diisi.'
    return
  }
  saving.value = true
  try {
    const uploaded = await uploadFile()
    const payload = {
      title: form.value.title.trim(),
      slug: form.value.slug.trim(),
      category: form.value.category,
      description: form.value.description.trim() || '-',
      published_at: new Date(form.value.published_at).toISOString(),
      ...(uploaded
        ? { file_url: uploaded.url, file_type: uploaded.type, file_size: uploaded.size }
        : {}),
    }
    if (editing.value) {
      if (!uploaded && !editing.value.file_url) throw new Error('Berkas wajib ada saat menyimpan dokumen baru.')
      const { error: e } = await supabase.from('documents').update(payload).eq('id', editing.value.id)
      if (e) throw e
    } else {
      const f = uploaded
      if (!f) throw new Error('Pilih berkas PDF/Word untuk dokumen baru.')
      const { error: e } = await supabase.from('documents').insert({
        ...payload,
        file_url: f.url,
        file_type: f.type,
        file_size: f.size,
        created_by: session.value!.user.id,
      })
      if (e) throw e
    }
    editing.value = null
    showForm.value = false
    await load()
  } catch (e) {
    err.value = (e as Error).message || 'Gagal menyimpan dokumen.'
  } finally {
    saving.value = false
  }
}

async function remove(d: Doc) {
  if (!confirm(`Hapus dokumen "${d.title}"?`)) return
  const { error } = await supabase.from('documents').delete().eq('id', d.id)
  if (error) {
    err.value = String((error as { message?: string }).message ?? "Gagal menghapus.")
    return
  }
  await load()
}
</script>

<template>
  <div class="max-w-5xl">
    <div class="flex items-center justify-between gap-4">
      <div>
        <h1 class="font-display text-2xl font-bold text-ink">Dokumen</h1>
        <p class="mt-1 text-sm text-ink-soft">Kelola dokumen unduhan publik.</p>
      </div>
      <button type="button" @click="openNew" class="rounded-md bg-brand-blue px-4 py-2 text-sm font-medium text-white hover:bg-brand-blue/90">
        + Dokumen Baru
      </button>
    </div>

    <p v-if="err" class="mt-4 rounded-md bg-danger/10 p-3 text-sm text-danger" role="alert">{{ err }}</p>

    <form v-if="showForm" @submit.prevent="save" class="mt-6 grid gap-4 rounded-xl bg-white p-6 ring-1 ring-border">
      <div class="grid gap-4 md:grid-cols-2">
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Judul *</span>
          <input v-model="form.title" name="title" required class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link" />
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Slug *</span>
          <input v-model="form.slug" name="slug" required :placeholder="slugify(form.title)" class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link" />
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Kategori</span>
          <select v-model="form.category" name="category" class="rounded-md border border-border px-3 py-2 text-ink">
            <option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
          </select>
        </label>
        <label class="grid gap-1 text-sm">
          <span class="font-medium text-ink">Tanggal terbit</span>
          <input v-model="form.published_at" name="published_at" type="date" class="rounded-md border border-border px-3 py-2 text-ink" />
        </label>
      </div>
      <label class="grid gap-1 text-sm">
        <span class="font-medium text-ink">Deskripsi</span>
        <textarea v-model="form.description" name="description" rows="2" class="rounded-md border border-border px-3 py-2 text-ink focus:outline-2 focus:outline-link"></textarea>
      </label>
      <label class="grid gap-1 text-sm">
        <span class="font-medium text-ink">{{ editing ? 'Ganti berkas (kosongkan untuk tetap)' : 'Berkas *' }}</span>
        <input
          name="file"
          type="file"
          accept=".pdf,.doc,.docx"
          class="rounded-md border border-border px-3 py-2 text-ink file:mr-3 file:rounded-md file:border-0 file:bg-brand-blue file:px-3 file:py-1.5 file:text-sm file:text-white"
          @change="form.file = ($event.target as HTMLInputElement).files?.[0] ?? null"
        />
        <span v-if="editing?.file_url" class="text-xs text-muted">Saat ini: <a :href="storageUrl(editing.file_url) ?? '#'" target="_blank" rel="noopener" class="text-link underline">{{ editing.file_url.split('/').pop() }}</a></span>
      </label>
      <div class="flex gap-3">
        <button type="submit" :disabled="saving" class="rounded-md bg-brand-blue px-5 py-2 text-sm font-medium text-white disabled:opacity-60">
          {{ saving ? 'Menyimpan…' : 'Simpan' }}
        </button>
        <button type="button" @click="editing = null; showForm = false; form = { title: '', slug: '', category: 'regulasi', description: '', file: null, published_at: new Date().toISOString().slice(0, 10) }" class="rounded-md bg-white px-5 py-2 text-sm font-medium ring-1 ring-border">
          Batal
        </button>
      </div>
    </form>

    <div v-if="loading" class="mt-8 py-10 text-center text-muted">Memuat…</div>
    <div v-else class="mt-6 overflow-hidden rounded-xl bg-white ring-1 ring-border">
      <table class="w-full text-left text-sm">
        <thead class="bg-surface text-xs uppercase tracking-wide text-muted">
          <tr>
            <th class="px-4 py-3">Judul</th>
            <th class="hidden px-4 py-3 md:table-cell">Kategori</th>
            <th class="px-4 py-3">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-border">
          <tr v-for="d in docs" :key="d.id" class="hover:bg-brand-blue-soft/40">
            <td class="px-4 py-3 text-ink">{{ d.title }}</td>
            <td class="hidden px-4 py-3 text-ink-soft md:table-cell">{{ d.category }}</td>
            <td class="px-4 py-3">
              <button type="button" @click="openEdit(d)" class="font-medium text-link hover:underline">Ubah</button>
              <span class="mx-2 text-border">·</span>
              <button type="button" @click="remove(d)" class="font-medium text-danger hover:underline">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <p v-if="!docs.length" class="p-6 text-center text-muted">Belum ada dokumen.</p>
    </div>
  </div>
</template>